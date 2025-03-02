# **AWS EKS - Kubernetes on AWS** 🚀  

---

## **1️⃣ Creating an EKS Cluster**
### **Command to Create the Cluster**
To create an **EKS cluster**, I specified:
- **Cluster Name:** `k8s-homework`
- **Region:** `us-east-1`
- **VPC CIDR Block:** `10.0.0.0/16`
- **K8s Version:** `1.31`
- **Node Type:** `t3.medium`
- **Auto-configure `kubectl` context**

```sh
eksctl create cluster --name k8s-homework --region us-east-1 --vpc-cidr 10.0.0.0/16 --nodes 2 --node-type t3.medium --version 1.31 --set-kubeconfig-context --write-kubeconfig
```

---

## **2️⃣ Configuring `kubectl` for EKS**
If `kubectl` is not automatically configured, run:

```sh
aws eks update-kubeconfig --region us-east-1 --name k8s-homework
```

✅ **Cluster Verification (`kubectl get nodes`)**
![Pasted image 20241229011458](https://github.com/user-attachments/assets/79651012-0f75-4769-8f25-1149e0968004)

---

## **3️⃣ Deploying a Static Web Page on EKS**
### **1. Creating an Nginx Deployment**
Deployed **Nginx** using a **ConfigMap** to serve a custom `index.html`.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        resources:
          limits:
            memory: "128Mi"
            cpu: "500m"
        volumeMounts:
        - mountPath: "/usr/share/nginx/html"
          name: config-volume
        ports:
        - containerPort: 80
      volumes:
      - name: config-volume
        configMap:
          name: nginx-index-html
```

---

### **2. Creating a `ConfigMap` for `index.html`**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-index-html
data:
  index.html: |
    <html>
      <body>
        <h1>Hello, it's me EKS web cluster!</h1>
      </body>
    </html>
```

---

### **3. Creating a LoadBalancer Service**
Used an **AWS Network Load Balancer (NLB)** to expose the application via a public **DNS**.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
    - port: 80
      targetPort: 80
  type: LoadBalancer
```

✅ **NLB Service Running (`kubectl get svc`)**
![Pasted image 20241229024508](https://github.com/user-attachments/assets/f0fc3e45-890a-4c8d-b579-e81d9477e7bc)

---

## **4️⃣ Creating a Persistent Volume in EKS**
### **1. Enabling OIDC Provider for IAM**
```sh
eksctl utils associate-iam-oidc-provider --region=us-east-1 --cluster=k8s-homework --approve
```

### **2. Adding IAM Policy for EBS Access**
```sh
eksctl create iamserviceaccount --cluster k8s-homework --namespace kube-system --name ebs-csi-controller --attach-policy-arn arn:aws:iam::aws:policy/AmazonEBSCSIDriverPolicy --approve
```

### **3. Installing the EBS CSI Driver**
```sh
eksctl create addon --name aws-ebs-csi-driver --cluster k8s-homework --region us-east-1
```

✅ **Checking EBS CSI Pods (`kubectl get pods -n kube-system`)**
![Pasted image 20250104181347](https://github.com/user-attachments/assets/b24a2a47-5370-41f8-b2f5-9af51afa3719)

---

### **4. Creating a StorageClass for EBS**
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-storage
provisioner: ebs.csi.aws.com
volumeBindingMode: Immediate
parameters:
  type: gp3
  fstype: ext4
```

---

### **5. Creating a PVC for EBS**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ebs-storage
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: ebs-storage
```

---

### **6. Creating a Pod That Uses the PVC**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod
spec:
  containers:
  - name: pod
    image: nginx
    volumeMounts:
    - mountPath: "/data"
      name: ebs-claim
    resources:
      limits:
        memory: "128Mi"
        cpu: "500m"
  volumes:
  - name: ebs-claim
    persistentVolumeClaim:
      claimName: ebs-storage
```

✅ **PVC Successfully Bound (`kubectl get pvc`)**
![Pasted image 20250104183202](https://github.com/user-attachments/assets/f254f97b-7cc1-4fbe-8ad4-f0317fcfd1e7)

✅ **Pod Running (`kubectl get pods`)**
![Pasted image 20250104184135](https://github.com/user-attachments/assets/8e308927-cf8b-4edc-b21e-959337cef403)

---

## **5️⃣ Running a Job in EKS**
### **Creating a Job to Run a Bash Command**
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: bash
spec:
  template:
    spec:
      containers:
      - name: bash
        image: docker.io/library/bash:5
        command: ["bash"]
        args:
        - -c
        - echo "Hello from EKS!" && echo "Job $job_uid"
        env:
        - name: job_uid
          valueFrom:
            fieldRef:
              fieldPath: metadata.uid
      restartPolicy: Never
```

✅ **Job Completed Successfully**
![Pasted image 20250104190242](https://github.com/user-attachments/assets/5a9e1b77-3026-4dbc-9ecc-68744be88f3c)

---

## **6️⃣ Deploying a Test Application**
### **Creating a Simple Nginx Deployment**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        resources:
          limits:
            memory: "128Mi"
            cpu: "500m"
        ports:
        - containerPort: 80
```

✅ **Deployment Running (`kubectl get deployments`)**
![Pasted image 20250104192150](https://github.com/user-attachments/assets/0b7ab7ad-d571-47f5-949d-8ccbff052463)

✅ **Testing Internal Connectivity with `curl`**
![Pasted image 20250104192716](https://github.com/user-attachments/assets/51a0ad7c-6809-4fda-9c0a-d1a8ef936b5c)

---

## **7️⃣ Working with Namespaces**
### **Creating a Namespace**
```sh
kubectl create namespace dev
```

### **Deploying `busybox` in `dev` Namespace**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: busybox
  namespace: dev
spec:
  replicas: 5
  selector:
    matchLabels:
      app: busybox
  template:
    metadata:
      labels:
        app: busybox
    spec:
      containers:
      - name: busybox
        image: busybox:stable
        command: ["sleep", "3600"]
        resources:
          limits:
            memory: "128Mi"
            cpu: "500m"
```

✅ **Namespace & Deployment Verified**
![Pasted image 20250104193626](https://github.com/user-attachments/assets/714d5e06-d863-4af0-925b-7ceddd5bea7f)

---

## **8️⃣ Deleting the Cluster**
### **To Clean Up Resources**
```sh
eksctl delete cluster k8s-homework
```