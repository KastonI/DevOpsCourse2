# **Self-Hosted Kubernetes (K8s)**
---

## **1️⃣ Task: Creating a StatefulSet for Redis Cluster**
**Before starting**, I created a **separate Namespace** and allowed **pods to run on the master node** using:

```sh
kubectl taint nodes k8s-master node-role.kubernetes.io/control-plane:NoSchedule-
```

---

### **1. Creating PersistentVolumeClaim**
I created **PV (PersistentVolume) and PVC (PersistentVolumeClaim)** manifests with the following settings:
- **Size:** `3Gi`
- **Access Mode:** `ReadWriteOnce`
- **Reclaim Policy:** `Retain`

---

### **2. Creating a Service for Redis**
I also created a **Service** with an open port to allow **Redis communication**.  
Additionally, I used `clusterIP: None` so that services communicate via **DNS names** instead of IP addresses.

---

### **3. Creating a StatefulSet for Redis**
- The **StatefulSet** has **two replicas**.
- Additional **volumes** are defined via `volumeClaimTemplates`.

After applying these manifests, I **verified the deployment** using:

```sh
kubectl get all -n hw-20
```

### **Result:**
![Pasted image 20241116200030](https://github.com/user-attachments/assets/035a6a09-e8eb-4bcf-b18e-1353c0c050cf)

To check **PersistentVolumes and Claims**, I ran:

```sh
kubectl get pv -n hw-20
```

### **Result:**
![Pasted image 20241116205324](https://github.com/user-attachments/assets/549f2c85-0d09-4f92-81c5-3e8c52f04ba3)

---

### **4. Verifying Data Persistence**
To test if **data persists**, I:
1. **Saved data** inside `redis-0`
2. **Deleted the pod**
3. **Checked if the data persisted** after the pod restarted

### **Step 1: Saving Data in Redis**
![Pasted image 20241116232544](https://github.com/user-attachments/assets/bccc8d04-2c94-4fbe-9e81-ec2aa067638a)

### **Step 2: Deleting and Restarting the Pod**
I deleted `redis-0` and checked if the data was still available.

### **Step 3: Verifying Data Persistence**
![Pasted image 20241116232825](https://github.com/user-attachments/assets/6c086f3e-6229-4a0b-b5fd-19fdba6e327a)

✅ **Confirmed:** Data **remains even after deleting the StatefulSet** and redeploying it.

---

## **2️⃣ Task: Configuring Falco in K8s**
Initially, I **tried writing a DaemonSet manually**, but pods **failed to start**.  
After researching, I found a **template for creating Falco as a DaemonSet**.

---

### **1. Modifying the DaemonSet Configuration**
✅ **Added Falco Startup Arguments**
- Logs are **formatted as JSON**
- Logs are **printed to the console**

```yaml
args:
  - "/usr/bin/falco"
  - "-o"
  - "program_output.enabled=true"
  - "-o"
  - "program_output.program=echo"
  - "-o"
  - "json_output=true"
```

✅ **Added Resource Requests & Limits**
```yaml
requests:
  memory: "128Mi"
  cpu: "100m"
limits:
  memory: "256Mi"
  cpu: "100m"
```

✅ **Mounted Necessary Directories**
```yaml
- mountPath: /host/var/run/docker.sock
  name: docker-socket
- mountPath: /host/dev
  name: dev-fs
- mountPath: /host/proc
  name: proc-fs
  readOnly: true
- mountPath: /host/boot
  name: boot-fs
  readOnly: true
- mountPath: /host/lib/modules
  name: lib-modules
  readOnly: true
- mountPath: /host/usr
  name: usr-fs
  readOnly: true
```

---

### **2. Verifying Falco Logs**
After applying the DaemonSet, I **triggered some security events** and received the following logs:

```json
{
  "hostname":"falco-vz6z7",
  "output":"2024-11-17T01:47:37.956370945+0000: Warning Sensitive file opened for reading by non-trusted program (file=/etc/pam.d/common-auth ... process=9 proc_exepath=/usr/lib/systemd/systemd-executor parent=systemd command=9 --deserialize 111 --log-level info --log-target journal-or-kmsg terminal=0 container_id=host container_name=host)",
  "priority":"Warning",
  "rule":"Read sensitive file untrusted",
  "source":"syscall",
  "tags":["T1555","container","filesystem","host","maturity_stable","mitre_credential_access"]
}
```

### **Screenshots:**
Falco **DaemonSet Running**
![Pasted image 20241117005921](https://github.com/user-attachments/assets/b4193152-8e8d-41bc-bd58-79a6ec1207fa)

Falco **Detected Unauthorized File Access**
![Pasted image 20241117014113](https://github.com/user-attachments/assets/16156b52-8247-4374-8f22-416a51a3afe5)
