## AWS EKS
### 1. Створити кластер EKS
Спочатку створюємо кластер з визначеним ім'ям, регiоном, CIDR-блоком, версiєю `K8s` i типом ноди `t3.medium`. Також я додав опцiї для автоматичного налаштування контексту в `kubectl`.

	eksctl create cluster --name k8s-homework --region us-east-1 --vpc-cidr 10.0.0.0/16 --nodes 2 --node-type t3.medium --version 1.31 --set-kubeconfig-context --write-kubeconfig

### 2. Налаштувати kubectl для доступу до кластера
Так як ми це виконали аргументами вище цього робити не треба, але якщо не спрацювало можна виконати наступну команду. 

	aws eks update-kubeconfig --region us-east-1 --name k8s-homework

Вивiд команди `kubectl get nodes`.

![Pasted image 20241229011458](https://github.com/user-attachments/assets/79651012-0f75-4769-8f25-1149e0968004)

### 3. Розгорнути статичний вебсайт

Деплоймент `nginx` з використанням `ConfigMap`. 

```
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

Створення `ConfigMap.yaml` для того щоб передати сторiнку `index.html` в кластер K8s.

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-index-html
data:
  index.html:
    <html>
      <body>
        <h1>Hello, it's me EKS web cluster!</h1>
      </body>
    </html>
```

А також сервiс **NLB**, через **DNS** якого можна зайти на створений `deployment`.

```
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

![Pasted image 20241229024508](https://github.com/user-attachments/assets/f0fc3e45-890a-4c8d-b579-e81d9477e7bc)

### 4. Створити PersistentVolumeClaim для збереження даних

Ввiмкнення OIDC полiтики K8s, щоб можна було отримати доступ до IAM ролей.

	eksctl utils associate-iam-oidc-provider --region=us-east-1 --cluster=k8s-homework --approve

Додавння IAM полiтики до поду через сервiсний аккаунт.

	eksctl create iamserviceaccount --cluster k8s-homework --namespace kube-system --name ebs-csi-controller --attach-policy-arn arn:aws:iam::aws:policy/AmazonEBSCSIDriverPolicy --approve

Створення адону `ebs` для класстеру `k8s-homework`. 

	eksctl create addon --name aws-ebs-csi-driver --cluster k8s-homework --region us-east-1

Перевiрка створених подiв адону.

	kubectl get pods -n kube-system

![Pasted image 20250104181347](https://github.com/user-attachments/assets/b24a2a47-5370-41f8-b2f5-9af51afa3719)

Пiсля цього пишемо **StorageClass** який використовує адон **EBS**. З типом `gp3`, а також файловою системою `ext4`.

```
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

Далi створюємо звичайний **PVC** який використовує **EBS**.

```
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

А також **Pod** який використовує **PVC** i монтує **volume** в `/data`.

```
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

Для перевiрки я використав команду `kubectl get pvc` вивiд показав **Status: bound** що свiдчить про успiшне монтування **StorageClass**.  

![Pasted image 20250104183202](https://github.com/user-attachments/assets/f254f97b-7cc1-4fbe-8ad4-f0317fcfd1e7)

А також `kubectl get pods` i перевiрив чи працює **pod**.

![Pasted image 20250104184135](https://github.com/user-attachments/assets/8e308927-cf8b-4edc-b21e-959337cef403)

### 5. Запуск завдання за допомогою Job

Я створив **Job** на основi `docker.io/library/bash:5`, який спочатку пише привiтання, а потiм вiдсилає свiй **uid**.

```
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

Вiн виконався без усiляких проблем.

![Pasted image 20250104190242](https://github.com/user-attachments/assets/5a9e1b77-3026-4dbc-9ecc-68744be88f3c)

### 6. Розгорнути тестовий застосунок

Розгорнув простенький **Deployment** за допомогою **nginx**.
```
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

![Pasted image 20250104192150](https://github.com/user-attachments/assets/0b7ab7ad-d571-47f5-949d-8ccbff052463)

А також сервiс **ClusterIP**.

```
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
  type: ClusterIP
```

Для перевiрки того що застосунок доступний у серединi кластеру можна використати спецiальний под.

	kubectl run curlpod --image=curlimages/curl -it -- sh

За допомогою команди я знайшов Ip який використовує deployment i зробив `curl` з поду у серединi кластеру.

	kubectl get pods -o wide

![Pasted image 20250104192150 1](https://github.com/user-attachments/assets/451bee93-2d48-49ed-b323-d33765c4b619)

![Pasted image 20250104192716](https://github.com/user-attachments/assets/51a0ad7c-6809-4fda-9c0a-d1a8ef936b5c)

### 7. Робота з неймспейсами
Створюємо **Namespace** **dev**.

	kubectl create namespace dev

**Deployment** для образу **busybox** з 5 реплiками i командою `sleep 3600`. 

```
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

Перевiрка

![Pasted image 20250104193626](https://github.com/user-attachments/assets/714d5e06-d863-4af0-925b-7ceddd5bea7f)

### 8. Очистити ресурси

Ну для цього є унiверсальна команда `eksctl delete cluster k8s-homework`)))
