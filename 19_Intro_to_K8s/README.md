# **Intro to Kubernetes**

> **For this task, I used local resources. The cluster consists of** 1 **master node and** 1 **worker node.**

---

## **1️⃣ Allow Pods on the Master Node**
By default, **pods do not run on the master node**. To allow pod scheduling on the master, I used:

```sh
kubectl taint nodes k8s-master node-role.kubernetes.io/control-plane:NoSchedule-
```

---

## **2️⃣ Creating a Namespace and Resource Quotas**
For this homework, I created a **separate namespace** to deploy the application and defined **ResourceQuotas**.

✅ **Both were combined into a single file:** `NamespaceAndResourceQuota.yaml`

Applied using:

```sh
kubectl apply -f NamespaceAndQuotas.yaml
```

---

## **3️⃣ PersistentVolume (PV) and PersistentVolumeClaim (PVC)**
I created a **PersistentVolume** with the following configuration:
- **Size:** `2Gi`
- **Access Mode:** `ReadWriteMany`
- **Reclaim Policy:** `Retain`

Then, I created a **PersistentVolumeClaim** (PVC) to bind to it.

Applied using:

```sh
kubectl apply -f PV.yaml
kubectl apply -f PVC.yaml
```

---

## **4️⃣ Creating a Service**
I created a **ClusterIP Service** to **enable communication** between pods **inside the cluster** (but **not externally**).

✅ **Service Configuration:**
- **Type:** `TCP`
- **Port:** `80`
- **Target Port:** `8080`

Applied using:

```sh
kubectl apply -f Service.yaml
```

---

## **5️⃣ Secrets & ConfigMap**
Since I didn't have real **sensitive credentials**, I simulated **database credentials**.

### **Secret Configuration (Base64-encoded)**
```yaml
data:
  username: dXNlcg==  # "user"
  password: cGFzc3dvcmQ=  # "password"
type: Opaque
```

### **ConfigMap Configuration (For Nginx)**
This config is **mounted as a file** in `/etc/nginx/nginx.conf`.

```yaml
data:
  nginx.conf: |
    worker_processes  1;

    events {
      worker_connections  1024;
    }

    http {
      server {
        listen 80;
        server_name localhost;

        location / {
          root /usr/share/nginx/html;
          index index.html index.htm;
        }
      }
    }
```

Applied using:

```sh
kubectl apply -f Secret.yaml
kubectl apply -f ConfigMap.yaml
```

---

## **6️⃣ Deployment Configuration**
For the **Nginx deployment**, I defined:

✅ **Key Settings:**
- **Replicas:** `2` (**One pod per node**)
- **Resource Limits:**
  ```yaml
  limits:
    memory: "256Mi"
    cpu: "500m"
  ```

✅ **Mounted Volumes:**
- **Persistent storage** for HTML pages (`index.html`)
- **ConfigMap** for `nginx.conf`

```yaml
- mountPath: /usr/share/nginx/html
  name: nginx-storage
- name: nginx-config-volume
  mountPath: /etc/nginx/nginx.conf
  subPath: nginx.conf
```

✅ **Environment Variables from Secrets**
```yaml
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

Applied using:

```sh
kubectl apply -f Deployment.yaml
```

---

## **7️⃣ Verification of Manifests**
To check the **current state of all resources**, I used:

```sh
kubectl get all -n homework -o wide
```

### **Result:**
![Pasted image 20241116182147](https://github.com/user-attachments/assets/799bc460-bf66-45f2-9ff6-62fd599b9a03)

To verify **PersistentVolumes**, I used:

```sh
kubectl get pv
```

### **Result:**
![Pasted image 20241116182237](https://github.com/user-attachments/assets/5e6e80bf-a295-4fec-a854-fd6cc07666a4)

---

## **8️⃣ Testing Inside the Container**
To **verify the mounted ConfigMap and Secrets**, I used `kubectl exec` to enter the pod.

```sh
kubectl exec -n homework -ti nginx-deployment-5bc559f685-jtvp7 -- sh
```

### **Checking the Config File and Environment Variables**
![Pasted image 20241116182748](https://github.com/user-attachments/assets/6cfad895-0625-44bc-9587-b05b1b244051)
![Pasted image 20241116182830](https://github.com/user-attachments/assets/ed62151e-bafd-4e4b-8263-89c4f7cd81e4)

---

## **9️⃣ Testing External Access via Port Forwarding**
To test **Nginx service**, I forwarded port `8080` to `80`:

```sh
kubectl port-forward svc/nginx-service 8080:80 -n homework
```

### **Result:**
![Pasted image 20241116184412](https://github.com/user-attachments/assets/66f5405e-060e-4d33-bab7-86c7ce1ba7af)