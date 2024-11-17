# Selfhosted K8s

## Завдання 1: Створення StatefulSet для Redis-кластера

**До виконання основного завдання створив Namespace, а також командою з попереднього дз дозволив розгортати поди на мастерi.**
### Створіть PersistentVolumeClaim

Для цього я створив файл `PV` и `PVC` манiфести з налаштуваннями:
- Size - **3Gi**
- Access Mode - **ReadWriteOnce**
- Reclaim Policy - **Retain**

### Створіть Service для Redis

Також я створив сервiс з вiдкритим портом за яким спiлкується Redis. А також використав параметр `clusterIP: None` для того щоб сервiси спiлкувались за DNS iменами.
### Створіть StatefulSet для Redis

Я створив StatefulSet, який має двi реплiки. А також додатковi volume якi доданi через `volumeClaimTemplates`.

I додав всi цi манiфести звичайними командами.

Потiм для перевiрки, я використав команди 

	kubectl get all -n hw-20

![Pasted image 20241116200030](https://github.com/user-attachments/assets/035a6a09-e8eb-4bcf-b18e-1353c0c050cf)

А щоб подивитись iнформацiю про `PV` i `PVC` цю команду

	kubectl get pv -n hw-20

![Pasted image 20241116205324](https://github.com/user-attachments/assets/549f2c85-0d09-4f92-81c5-3e8c52f04ba3)

### Перевiрка даних

Щоб перевiрити чи зберiгаються даннi я вирiшив спробувати зберегти даннi, видалити под, а потiм подивитись чи перезапустився под з назвою `redis-0`.

Я зберiг даннi у подi `redis-0`

![Pasted image 20241116232544](https://github.com/user-attachments/assets/bccc8d04-2c94-4fbe-9e81-ec2aa067638a)

Пiсля цього я видалив його. Пiсля запуску я знову зайшов на цей контейнер i спробував вивiсти даннi якi я записав ранiше.

![Pasted image 20241116232825](https://github.com/user-attachments/assets/6c086f3e-6229-4a0b-b5fd-19fdba6e327a)

Це спрацювало навiть якщо видалити весь `StatefulSet`, i запустити його знову.


## Завдання 2: Налаштування Falco за допомогою K8s

Я спочатку сам спробував написати `DaemonSet`, поди наче створились але не запустились. Потiм я почав шукати iнформацiю i знайшов темплейт для створення `DaemonSet`.

Я його трохи модифiкував i в мене вийшов варiант який запустився. Через проблеми з модулем ядра bpf я доволi довго не мiг перевiрити працездатнiсть `falco`, але все ж таки в мене вийшло отримати логи на основi правил.

У нього я додав аргументи для запуску `falco`, виводу логiв у консоль, а також форматувати у json.

```
args:
  - "/usr/bin/falco"
  - "-o"
  - "program_output.enabled=true"
  - "-o"
  - "program_output.program=echo"
  - "-o"
  - "json_output=true"
```

Додав лiмiти i запити згiдно файлу домашнього завдання

```
requests:
  memory: "128Mi"
  cpu: "100m"
limits:
  memory: "256Mi"
  cpu: "100m"
```
А також примонтував необхiднi дерикторiї

```
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

Пiсля застосування цього DaemonSet, я зробив декiлька тригерних дiй i отримав наступнi логи.

```
  /common-auth","proc.aname[2]":null,"proc.aname[3]":null,"proc.aname[4]":null,"proc.cmdline":"9 --deserialize 111 --log-level info --log-target journal-or-kmsg","proc.exepath":"/usr/lib/systemd/systemd-executor","proc.name":"9","proc.pname":"systemd","proc.tty":0,"user.loginuid":-1,"user.name":"root","user.uid":0},"priority":"Warning","rule":"Read sensitive file untrusted","source":"syscall","tags":["T1555","container","filesystem","host","maturity_stable","mitre_credential_access"],"time":"2024-11-17T01:47:37.956370945Z"}
  {"hostname":"falco-vz6z7","output":"2024-11-17T01:47:37.956488161+0000: Warning Sensitive file opened for reading by non-trusted program (file=/etc/pam.d/common-account gparent=<NA> ggparent=<NA> gggparent=<NA> evt_type=openat user=root user_uid=0 user_loginuid=-1 process=9 proc_exepath=/usr/lib/systemd/systemd-executor parent=systemd command=9 --deserialize 111 --log-level info --log-target journal-or-kmsg terminal=0 container_id=host container_name=host)","output_fields":{"container.id":"host","container.name":"host","evt.time.iso8601":1731808057956488161,"evt.type":"openat","fd.name":"/etc/pam.d/common-account","proc.aname[2]":null,"proc.aname[3]":null,"proc.aname[4]":null,"proc.cmdline":"9 --deserialize 111 --log-level info --log-target journal-or-kmsg","proc.exepath":"/usr/lib/systemd/systemd-executor","proc.name":"9","proc.pname":"systemd","proc.tty":0,"user.loginuid":-1,"user.name":"root","user.uid":0},"priority":"Warning","rule":"Read sensitive file untrusted","source":"syscall","tags":["T1555","container","filesystem","host","maturity_stable","mitre_credential_access"],"time":"2024-11-17T01:47:37.956488161Z"}
  {"hostname":"falco-vz6z7","output":"2024-11-17T01:47:37.956507869+0000: Warning Sensitive file opened for reading by non-trusted program (file=/etc/pam.d/common-password gparent=<NA> ggparent=<NA> gggparent=<NA> evt_type=openat user=root user_uid=0 user_loginuid=-1 process=9 proc_exepath=/usr/lib/systemd/systemd-executor parent=systemd command=9 --deserialize 111 --log-level info --log-target journal-or-kmsg terminal=0 container_id=host container_name=host)","output_fields":{"container.id":"host","container.name":"host","evt.time.iso8601":1731808057956507869,"evt.type":"openat","fd.name":"/etc/pam.d/common-password","proc.aname[2]":null,"proc.aname[3]":null,"proc.aname[4]":null,"proc.cmdline":"9 --deserialize 111 --log-level info --log-target journal-or-kmsg","proc.exepath":"/usr/lib/systemd/systemd-executor","proc.name":"9","proc.pname":"systemd","proc.tty":0,"user.loginuid":-1,"user.name":"root","user.uid":0},"priority":"Warning","rule":"Read sensitive file untrusted","source":"syscall","tags":["T1555","container","filesystem","host","maturity_stable","mitre_credential_access"],"time":"2024-11-17T01:47:37.956507869Z"}
  {"hostname":"falco-vz6z7","output":"2024-11-17T01:47:37.956525654+0000: Warning Sensitive file opened for reading by non-trusted program (file=/etc/pam.d/common-session gparent=<NA> ggparent=<NA> gggparent=<NA> evt_type=openat user=root user_uid=0 user_loginuid=-1 process=9 proc_exepath=/usr/lib/systemd/systemd-executor parent=systemd command=9 --deserialize 111 --log-level info --log-target journal-or-kmsg terminal=0 container_id=host container_name=host)","output_fields":{"container.id":"host","container.name":"host","evt.time.iso8601":1731808057956525654,"evt.type":"openat","fd.name":"/etc/pam.d/common-session","proc.aname[2]":null,"proc.aname[3]":null,"proc.aname[4]":null,"proc.cmdline":"9 --deserialize 111 --log-level info --log-target journal-or-kmsg","proc.exepath":"/usr/lib/systemd/systemd-executor","proc.name":"9","proc.pname":"systemd","proc.tty":0,"user.loginuid":-1,"user.name":"root","user.uid":0},"priority":"Warning","rule":"Read sensitive file untrusted","source":"syscall","tags":["T1555","container","filesystem","host","maturity_stable","mitre_credential_access"],"time":"2024-11-17T01:47:37.956525654Z"}
```

Скрiншоти роботи `DaemonSet`

![Pasted image 20241117005921](https://github.com/user-attachments/assets/b4193152-8e8d-41bc-bd58-79a6ec1207fa)

![Pasted image 20241117014113](https://github.com/user-attachments/assets/16156b52-8247-4374-8f22-416a51a3afe5)
