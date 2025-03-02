# **Docker Swarm**

---

## **Task 1: Initializing the Docker Swarm Cluster**

### **Initializing the Swarm Cluster**
To initialize the **Swarm cluster**, I used the following command:

```sh
docker swarm init
```

---

### **Adding a Worker Node**
Then, using the command displayed on the **master node**, I added a **worker node** to the cluster:

```sh
docker swarm join --token SWMTKN-1-6863n9ffffv2c5ysz51sogjdb7rch314h7c45bgiip3n4htn84-1rznttqu9z5kd6a1h37idpqlm 10.10.10.13:2377
```

---

### **Checking Cluster Status**
To verify that the **Swarm cluster** is working correctly:

```sh
docker node ls
```

### **Result:**
![Pasted image 20241106181601](https://github.com/user-attachments/assets/c116653d-7b2b-437f-a0e3-9b4ebd036b54)

---

## **Task 2: Creating and Managing Services**

### **1️⃣ Creating a Simple Nginx Web Service**
I started an **Nginx container** on the master node using:

```sh
docker service create --name web --publish published=8080,target=80 nginx
```

To move the container to a **worker node**, I updated its constraints:

```sh
docker service update web --constraint-add 'node.hostname == srv-2'
```

### **Issue:**  
This **broke automatic load balancing** within the Swarm cluster. I later removed this constraint and learned that **priority scheduling can be configured using labels**.

### **2️⃣ Scaling the Web Service to 3 Replicas**
To **scale the web service**, I used:

```sh
docker service scale web=3
```

### **Result:**
![Pasted image 20241106221334](https://github.com/user-attachments/assets/0c80896a-d3a1-438f-be7b-1a3f97f6fa75)

The service is now running, and **the webpage is accessible**.

![Pasted image 20241106221429](https://github.com/user-attachments/assets/df6b0519-7b88-44f6-880d-5d297081ffc7)

---

## **Tasks 3 & 4: Creating a Stack and Using Secrets**

To **deploy the Flask application** from my previous homework, I first **built** the application and pushed it to **Docker Hub**.

✅ **Available on Docker Hub:**  
`kastonl/web-flask:latest`

Since the application **uses `.env` variables**, sensitive credentials were **not included** in the image—only **environment variable placeholders**.

---

### **Changes to `docker-compose.yaml`**
#### **1️⃣ Added Restart Policies for Each Container**
```yaml
deploy:
  restart_policy:
    condition: on-failure
```

#### **2️⃣ Defined 3 Replicas for `web`**
```yaml
replicas: 3
```

#### **3️⃣ Removed Incompatible Features**
Since **Swarm mode does not support**:
- `depends_on`
- `container_name`
- `expose`

I **removed them**.

#### **4️⃣ Using Secrets for Sensitive Credentials**
```yaml
secrets:
  - REDIS_PASSWORD
  - POSTGRES_USER
  - POSTGRES_PASSWORD
environment:
  - REDIS_PASSWORD: /run/secrets/REDIS_PASSWORD
  - POSTGRES_USER: /run/secrets/POSTGRES_USER
  - POSTGRES_PASSWORD: /run/secrets/POSTGRES_PASSWORD
```

#### **5️⃣ Using Configs for Shared Configuration Files**
Since **configs should be available on all nodes**, I added them to `configs`:

```yaml
configs:
  nginx_config:
    external: true
  db_init:
    external: true
  index_html:
    external: true
```

📌 **Note:**  
I **stored `index.html` in `configs`**, but if frequent updates are needed, **an external NFS server** would be a better option.

---

### **Adding Secrets and Configs to Docker Swarm**
I created **secrets** for **PostgreSQL** and **Redis** passwords:

```sh
echo "8mf2j4a8mr3" | docker secret create POSTGRES_PASSWORD -
echo "root" | docker secret create POSTGRES_USER -
echo "dm239gm2d8s" | docker secret create REDIS_PASSWORD -
```

I also added **configs** for the database initialization and Nginx:

```sh
docker config create db_init ./init/init.sql
docker config create index_html ./init/index.html
docker config create nginx_config ./init/default.conf
```

---

### **Handling Service Restarts in Swarm Mode**
After launching the **stack**, some services **crashed** due to missing dependencies (e.g., the **Flask app started before the database**). However, **Swarm automatically restarted them**, resolving the issue.

---

### **Final Result:**
✅ **All 6 containers successfully communicate and function properly**.  

![Pasted image 20241108170202](https://github.com/user-attachments/assets/e2ad780e-6ffd-431c-a5c6-950b5ed4c4e6)  
![Pasted image 20241108170206](https://github.com/user-attachments/assets/793e20bf-e2f2-4c0b-9b9a-dd133bead1b0)
