# Advanced Ansible

## Загальний опис

Для виконання цього завдання я спочатку підняв за допомогою **Terraform** два інстанси **public**, а також ще один інстанс, для якого буде використовуватись лише базова конфігурація (**baseline**).  
Всі інстанси мають теги `public/private instance`, що дозволяє використовувати **dynamic inventory**.

---

## Створення ролі "baseline" для базових налаштувань серверів

Я створив базову структуру ролі за допомогою **ansible-galaxy**:

```
ansible-galaxy init baseline
```

Після ініціалізації я видалив непотрібні файли, залишивши лише директорії `files` та `tasks`.

### Налаштування baseline

У ролі **baseline** я перевіряю, що під час створення інстансів було передано публічний ключ:

```
- name: Ensure SSH keys are configured
  authorized_key:
    user: ubuntu
    state: present
    key: "{{ lookup('file', 'files/instance_test_key.pub') }}"
```

Після цього оновлюється кеш та встановлюються базові пакети:

```
- name: Apt cache (apt update)
  apt:
    update_cache: yes

- name: Install packages vim, git, mc, ufw, htop
  apt:
    name:
      - vim
      - git
      - ufw
      - htop
    state: present
```

---

## Створення ролі для налаштування Firewall

У ролі **firewall** я спочатку ввімкнув логування, а потім додав правила для вхідного трафіку:

```
- name: Allow ports
  ufw:
    rule: allow
    port: "{{ item }}"
    proto: tcp
  with_items:
    - 22     # SSH
    - 80     # HTTP
    - 443    # HTTPS
```

Після встановлення правил ввімкнув **UFW** та вивів його статус:

```
- name: Allow everything and enable UFW
  ufw:
    state: enabled
    policy: deny

- name: Show UFW status
  command: ufw status verbose
  register: ufw_status

- debug:
    var: ufw_status.stdout_lines
```

---

## Створення ролі для налаштування Nginx

У ролі **nginx** виконуються наступні завдання:
- Встановлення **Nginx**
- Деплой файлу `index.html` за допомогою шаблону
- Копіювання конфігураційного файлу
- Перезапуск сервісу

```
- name: Install Nginx
  apt:
    name: nginx
    state: present

- name: Deploy index.html
  template:
    src: templates/index.html.j2
    dest: /var/www/html/index.html
    mode: '0644'

- name: Deploy default Nginx configuration file
  copy:
    src: files/nginx.conf
    dest: /etc/nginx/nginx.conf
    mode: '0644'
    owner: root
    group: root

- name: Restart Nginx
  service:
    name: nginx
    state: restarted
```

---

## Налаштування Dynamic Inventory

Для управління інфраструктурою я встановив модуль та створив файл `aws_ec2.yaml` з наступними налаштуваннями:

```
plugin: amazon.aws.aws_ec2
regions:
  - us-east-1
filters:
  instance-state-name: running
keyed_groups:
  - key: tags.instance
    prefix: instance_
compose:
  ansible_host: public_ip_address
  ansible_user: ubuntu
  ansible_ssh_private_key_file: /root/.ssh/instance_test_key
host_key_check: false
```

Цей конфігураційний файл групує інстанси за тегом `instance`, тому формуються дві групи:
- **instance__db**
- **instance__web**

За допомогою команди

```
ansible-inventory -i aws_ec2.yaml --list
```

можна перевірити, як інстанси групуються, наприклад:

```
"instance__db": {
    "hosts": [
        "ip-10-0-1-82.ec2.internal"
    ]
},
"instance__web": {
    "hosts": [
        "ip-10-0-1-99.ec2.internal",
        "ip-10-0-1-46.ec2.internal"
    ]
}
```

---

## Playbook

У основному playbook я додав використання створених ролей:

```
- name: Configure baseline
  hosts: all
  become: true
  roles:
    - baseline

- name: Configure public firewall
  hosts: all
  become: true
  roles:
    - firewall

- name: Configure Nginx instance
  hosts: instance__web
  become: true
  roles:
    - nginx
```

Запуск playbook здійснюється за допомогою наступної команди:

```
ansible-playbook playbook.yaml -i aws_ec2.yaml -u ubuntu --private-key=/root/.ssh/instance_test_key
```

---

## Шифрування конфіденційних даних за допомогою Ansible Vault

Для шифрування, наприклад, паролів, я використав команду:

```
ansible-vault create vault.yml
```

Після введення паролю відкрився редактор **nano**, в який я додав наступні дані:

```
ansible_user: ubuntu
SuperData: Ansible_vault
```

Щоб використовувати зашифровані змінні у playbook, я додав параметр:

```
vars_files:
  - vault.yml
```

Для перевірки роботи я вставив змінну у шаблон:

```
<h1>It works! {{ SuperData }}</h1>
```

Результат перевірив за допомогою команди `curl`:

```
root@ip-10-0-1-99:/home/ubuntu# curl http://localhost
<html>
<head>
    <title>Welcome to ip-10-0-1-99.ec2.internal</title>
</head>
<body>
    <h1>It works! Ansible_vault</h1>
</body>
</html>
```

---

## Конфігурація декількох Playbook для різних ситуацій

Я створив два окремих playbook:

### Перший Playbook

Використовує ролі **baseline**, **firewall** та **nginx**:

```
- name: Configure baseline
  hosts: all
  become: true
  roles:
    - baseline

- name: Configure public firewall
  hosts: all
  become: true
  roles:
    - firewall

- name: Configure Nginx instance
  hosts: instance__web
  become: true
  vars_files:
    - vault.yml
  roles:
    - nginx
```

Запуск:

```
ansible-playbook playbook.yaml -i aws_ec2.yaml -u ubuntu --private-key=/root/.ssh/instance_test_key --ask-vault-pass
```
Результат:

![image](https://github.com/user-attachments/assets/d7f5a0c3-4ca6-4d97-b759-14f1dd2574cb)

### Другий Playbook

Використовується лише для публічного інстансу з ролями **baseline** та **firewall**:

```
- name: Configure baseline
  hosts: all
  become: true
  roles:
    - baseline

- name: Configure public firewall
  hosts: instance__web
  become: true
  roles:
    - firewall
```

Запуск:

```
ansible-playbook playbook_2.yaml -i aws_ec2.yaml -u ubuntu --private-key=/root/.ssh/instance_test_key
```

Результат:

![image](https://github.com/user-attachments/assets/ff98b893-f9d7-4774-a44d-fb2a25eda518)
