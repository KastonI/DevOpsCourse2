# **Task 2: Creating a `docker-compose.yml` File**  

In my **Docker Compose** file, I defined **four services**:  
- **PostgreSQL** as the database  
- **Redis** as the caching server  
- **Web container** with Python and Flask  
- **Nginx** as a reverse proxy and load balancer  

---

### **Key Features in the `docker-compose.yml` File:**

#### **1️⃣ Environment Variables for Security**  
Passing **database credentials** via the `.env` file:

```yaml
environment:
  POSTGRES_USER: ${POSTGRES_USER}
  POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
  POSTGRES_DB: ${POSTGRES_DB}
```

#### **2️⃣ Internal Communication Between Services**  
Using `expose` to **allow communication between containers** without exposing ports externally:

```yaml
expose:
  - "5432:5432"
```

#### **3️⃣ Persistent Storage for Database Initialization**  
Mounting **volumes** for persistent storage and initializing the database with an `init.sql` script:

```yaml
volumes:
  - db-data:/var/lib/postgresql/data
  - ./init/init.sql:/docker-entrypoint-initdb.d/init.sql:ro
```

#### **4️⃣ Health Checks for Dependencies**  
Ensuring **Flask starts only after PostgreSQL is ready**:

```yaml
healthcheck:
  test: ["CMD", "pg_isready", "-U", "${POSTGRES_USER}","-d", "${POSTGRES_DB}"]
  start_period: 15s
  interval: 10s
  timeout: 5s
  retries: 3
```

#### **5️⃣ Secure Redis Configuration**  
Starting **Redis** with a password from the `.env` file:

```yaml
command: ["redis-server", "--requirepass", "${REDIS_PASSWORD}"]
```

#### **6️⃣ Nginx as a Reverse Proxy**  
Using **volumes** to mount the Nginx configuration file and `index.html`:

```yaml
volumes:
  - ./init/default.conf:/etc/nginx/conf.d/default.conf:ro
  - ./init/index.html:/usr/share/nginx/html/index.html
```

#### **7️⃣ Multi-Stage Build for Python Flask Application**  
Building the **web container** using `python:3.11-alpine`:

```yaml
build: ./web/
```

#### **8️⃣ Dependency Management for Flask**  
Flask **waits for PostgreSQL and Redis** before starting:

```yaml
depends_on:
  db:
    condition: service_healthy
  redis:
    condition: service_started
```

#### **9️⃣ Exposing Flask Only Internally**  
To **prevent direct access** to Flask:

```yaml
expose:
  - "5000:5000"
```

---

## **Task 3: Running a Multi-Container Application**  

### **Check Running Services**  
I verified running containers using:

```sh
docker compose ps
```

### **Result:**  
![Pasted image 20241101184627](https://github.com/user-attachments/assets/e469a2a1-2c52-4ea9-960b-54bb376b6c84)

---

### **Check Web Server Functionality**  
After starting the containers, accessing `localhost:80` displays:  

![Pasted image 20241101184103](https://github.com/user-attachments/assets/8cd80b97-3626-470d-9b7c-da7069cc43b3)

Clicking the **button** retrieves data from PostgreSQL.  
The output includes the **container ID** that handled the request.  

On the first request, data is fetched from **PostgreSQL**:  

![Pasted image 20241101184151](https://github.com/user-attachments/assets/31787e80-8dc1-4d0f-b772-f02d95facf8d)

Reloading the page **uses Redis cache** instead:  

![Pasted image 20241101184356](https://github.com/user-attachments/assets/0fc8b145-020a-4069-b5b7-27d5bd2ed583)

---

## **Task 4: Network and Volume Configuration**  

### **Check Created Networks and Volumes**  
Using:

```sh
docker volume ls
docker network ls
```

I found **two volumes**:
1. **Database storage** (PostgreSQL)
2. **Redis cache storage**  

Docker also created a **custom network**:  
`multi-container-app_appnet`

---

### **Verify Database Connectivity**  
I accessed the PostgreSQL container:

```sh
docker exec -ti postgres-db sh
```

Checked imported data from `init.sql`:

```sh
psql -U root -d devops
SELECT * FROM test;
```

### **Result:**  
![Pasted image 20241102125507](https://github.com/user-attachments/assets/91500f6b-ff66-44eb-bfd7-3eb3e0c6d68e)

---

## **Task 5: Scaling Services**  

### **1️⃣ Add Hostname Information to Responses**  
To track **which container handles the request**, I modified the Flask app to display:

```python
response = { 'host_number': f'Hello from Flask running in {os.environ.get("HOSTNAME")}!' }
```

---

### **2️⃣ Modify Nginx for Load Balancing**  
Nginx now **proxies requests** from `localhost:80/data` to **Flask containers (`web`)**:

```nginx
location /data {
  proxy_pass http://web:5000/data;
}
```

With **Docker's built-in load balancing**, requests are distributed among **all running `web` containers**.

---

### **3️⃣ Scale Web Containers to 3 Instances**  
Running:

```sh
docker-compose up -d --scale web=3
```

### **Result:**  
![Pasted image 20241101185341](https://github.com/user-attachments/assets/2ee3ff3e-f5d9-45d4-95b0-c5f22c2c265f)

---

### **4️⃣ Verify Load Balancing**  
Reloading `localhost` multiple times shows **different containers handling requests**:

![Pasted image 20241101185449](https://github.com/user-attachments/assets/3a0266f6-4f5d-469c-afcf-04c86ca73cfe)
![Pasted image 20241101185427](https://github.com/user-attachments/assets/4d4d9526-1d04-4e40-b934-001e31a81170)
![Pasted image 20241101185425](https://github.com/user-attachments/assets/61076613-6403-40c9-bdff-a183312d94c5)

Each request cycles between **three different Flask containers**.