# Monitoring

## Розгорнути інфраструктуру

### Моніторинг-сервер

На цей сервер я інсталював **docker** та **docker-compose**.  
За допомогою файлу `docker-compose` я запустив наступні контейнери:

```yaml
version: '3.7'
services:
  loki:
    image: grafana/loki:latest
    container_name: loki
    volumes:
      - ./loki/config.yaml:/etc/loki/config.yaml
    ports:
      - "3100:3100"

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana_data:/var/lib/grafana

  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"

volumes:
  grafana_data:
```

А також налаштував **Node Exporter** та відповідний сервіс.

### Вебсервер

На цей інстанс я інсталював **nginx**, **node exporter** та **promtail**.  
Для **node exporter** та **promtail** також налаштував системні сервіси.

---

## Налаштувати Prometheus

Для цього я створив файл `prometheus.yml` з наступними джобами для моніторингу двох серверів та запущених контейнерів:

```yaml
global:
  scrape_interval: 5s

scrape_configs:
  - job_name: 'monitoring_server'
    static_configs:
      - targets: ['10.0.1.90:9100']

  - job_name: 'nginx_server'
    static_configs:
      - targets: ['10.0.1.99:9100']

  - job_name: 'prometheus_container'
    static_configs:
      - targets: ['prometheus:9090']

  - job_name: 'grafana_container'
    static_configs:
      - targets: ['grafana:3000']

  - job_name: 'loki_container'
    static_configs:
      - targets: ['loki:3100']

  - job_name: 'nginx_exporter'
    static_configs:
      - targets: ['10.0.1.99:9113']
```

### Вебсервер

На вебсервері я встановив **nginx exporter** для передачі метрик до **Prometheus**.  
Ці дані згодом відображатимуться на dashboard у **Grafana**.

---

## Налаштувати Loki

### Налаштування моніторинг-сервера

Налаштував файл `config.yaml` для зберігання логів на моніторинг-сервері:

```yaml
auth_enabled: false

server:
  http_listen_port: 3100

ingester:
  lifecycler:
    ring:
      kvstore:
        store: inmemory
      replication_factor: 1

schema_config:
  configs:
    - from: 2025-01-01
      store: boltdb
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 24h

storage_config:
  boltdb:
    directory: /loki/index
  filesystem:
    directory: /loki/chunks

limits_config:
  enforce_metric_name: false
  reject_old_samples: true
  reject_old_samples_max_age: 168h

chunk_store_config:
  max_look_back_period: 0s

table_manager:
  retention_deletes_enabled: true
  retention_period: 168h
```

### Налаштування вебсерверу

На вебсервері я інсталював **promtail** та запустив його з наступною конфігурацією, яка збирає логи системи та **nginx**.

Файл `promtail-config.yml`:

```yaml
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /var/log/positions.yaml

clients:
  - url: http://10.0.1.90:3100/loki/api/v1/push

scrape_configs:
  - job_name: journal
    journal:
      path: /var/log/journal
      labels:
        job: systemd-journal
    relabel_configs:
      - source_labels: ['__journal__systemd_unit']
        target_label: 'unit'

  - job_name: nginx_logs
    static_configs:
      - targets:
          - localhost
        labels:
          job: nginx
          host: webserver
          __path__: /var/log/nginx/*.log
```

---

## Налаштувати Grafana

Я налаштував джерела даних з **Loki** та **Prometheus**, а також створив кілька дашбордів:

### Node Exporter

- **Monitoring Server**
    
![Pasted image 20250203195011](https://github.com/user-attachments/assets/62517bbe-8142-4238-ae8d-bd98fac0f619)
    
- **Nginx Server**
    
![Pasted image 20250203195045](https://github.com/user-attachments/assets/74a113ce-47e1-4ea8-b090-6486369bf678)
    

### Nginx Exporter

**Prometheus** отримує дані з **nginx exporter** та відображає їх на дашборді:

![Pasted image 20250203203549](https://github.com/user-attachments/assets/98f4b6fb-3cc2-4f57-96d4-b3e15d9cf0ac)

### Loki Logs Explorer

Дашборди для перегляду логів **nginx** та системних логів:

![Pasted image 20250203205924](https://github.com/user-attachments/assets/480956c6-be11-493f-901d-070619c84eda)

![Pasted image 20250203210010](https://github.com/user-attachments/assets/af5f03fa-0a10-4913-84c2-0eab019d8704)
