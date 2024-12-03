
# Intro to K8s

>Для завдання використовувались локальнi ресурси. Усього було запущено 1 майстер i 1 воркер.

**Спершу для того щоб дозволити створення подiв на мастерi використав наступну команду**

    kubectl taint nodes k8s-master node-role.kubernetes.io/control-plane:NoSchedule-

## Namespace

Для цього домашнього завдання я створив окремий `Namespace` в якому буде розгортатись застосунок, а також для нього `ResourceQuota`.

Я їх об’єднав в один файл `NamespaceAndResourceQuota.yaml`, бо вони тiсно взаємо пов’язанi. I також застосував його командою:

	kubectl apply -f NamespaceAndQuotas.yaml

## PersistentVolume та PersistentVolumeClaim

Також я створив файл `PV` з налаштуваннями:
- Size - **2Gi**
- Access Mode - **ReadWriteMany**
- Reclaim Policy - **Retain**`

А також файл `PVC` до нього, пiсля цього застосував їх командами:

	kubectl apply -f PV.yaml
	kubectl apply -f PVC.yaml

## Service

Далi створив `Service` з типом `ClusterIP`. Який дозволяє доступ до контейнерiв в серединi кластеру, але не ззовнi.
Налаштування:
- Type - **TCP**
- Port - **80**
- Target Port - **8080**

Застосував командою:

	kubectl apply -f Service.yaml

## Secret i ConfigMap

Я не придумав який реальний секрет можна передати, тому передаємо даннi вiд уявної БД.
Попередньо я закодував їх в BASE64 i обрав тип `Opaque`.

	data:
	  username: dXNlcg==
	  password: cGFzc3dvcmQ=

Для `ConfigMap` я вирiшив передавати налаштування для Nginx. Вiн буде монтуватись у файл `/etc/nginx/nginx.conf`.

	data:
	  nginx.conf: |
	    worker_processes  1;
	  
	    events {
	      worker_connections  1024;
	    }
	  
	    http {
	      server {
	        listen       80;
	        server_name  localhost;
	  
	        location / {
	          root   /usr/share/nginx/html;
	          index  index.html index.htm;
	        }
	      }
	    }

Застосував їх командою:

	kubectl apply -f Secret.yaml
	kubectl apply -f ConfigMap.yaml

## Deployment

В `Deployment` файлi для Nginx я вказав наступнi параметри. 

Кiлькiсть реплiк - **2**, щоб було розгорнуто по одному екземпляру на кожнiй нодi.
Лiмiти для створених подiв.

	limits:
	  memory: "256Mi"
	  cpu: "500m"

Також на кожнiй нодi в створений волюм додав файли з сторiнками `index.html`. I файл конфiгурацiї з `ConfigMap`.

```
- mountPath: /usr/share/nginx/html
	name: nginx-storage
- name: nginx-config-volume
	mountPath: /etc/nginx/nginx.conf
	subPath: nginx.conf
```

А через `env` додав змiннi даннi з `Secret` для БД.

```
- name: USERNAME
    valueFrom:
	  secretKeyRef:
		name: mysecret
		key: username
- name: PASSWORD
	valueFrom:
	  secretKeyRef:
		name: mysecret
		key: password
```

Застосував командою:

	kubectl apply -f Deployment.yaml

## Перевiрка створених манiфестiв

Для цього я використав команди:

	kubectl get all -n homework -o wide

![Pasted image 20241116182147](https://github.com/user-attachments/assets/799bc460-bf66-45f2-9ff6-62fd599b9a03)

	kubectl get pv

![Pasted image 20241116182237](https://github.com/user-attachments/assets/5e6e80bf-a295-4fec-a854-fd6cc07666a4)

Використовуючи команду `exec` я зайшов у контейнер i перевiрив наявнiсть налаштованого config файлу, та глобальних змiнних.

	kubectl exec -n homework -ti nginx-deployment-5bc559f685-jtvp7 -- sh

![Pasted image 20241116182748](https://github.com/user-attachments/assets/6cfad895-0625-44bc-9587-b05b1b244051)

![Pasted image 20241116182830](https://github.com/user-attachments/assets/ed62151e-bafd-4e4b-8263-89c4f7cd81e4)



Також за допомогою `port-forwarding` я перевiрив роботу nginx сервiсу.

	kubectl port-forward svc/nginx-service 8080:80 -n homework

![Pasted image 20241116184412](https://github.com/user-attachments/assets/66f5405e-060e-4d33-bab7-86c7ce1ba7af)
