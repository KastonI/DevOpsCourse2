# **Advanced Ansible**

## **General Overview**

For this task, I used **Terraform** to launch two **public** instances and one additional **baseline** instance with only basic configurations.  
All instances are tagged as `public/private instance`, allowing **dynamic inventory** usage.

---

## **Creating the "baseline" Role for Basic Server Configuration**

I initialized the **baseline** role using **ansible-galaxy**:

```sh
ansible-galaxy init baseline
```

After initialization, I removed unnecessary files, keeping only the `files` and `tasks` directories.

### **Baseline Configuration**

The **baseline** role ensures that SSH keys are properly set up:

```yaml
- name: Ensure SSH keys are configured
  authorized_key:
    user: ubuntu
    state: present
    key: "{{ lookup('file', 'files/instance_test_key.pub') }}"
```

Then, it updates the package cache and installs essential packages:

```yaml
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

## **Creating a Firewall Role**

The **firewall** role enables logging and allows traffic for specific ports:

```yaml
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

Then, it enables **UFW** and displays its status:

```yaml
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

## **Creating an Nginx Role**

The **nginx** role performs the following tasks:
- Installs **Nginx**
- Deploys an `index.html` file using a **Jinja2 template**
- Copies the **Nginx configuration file**
- Restarts the **Nginx service**

```yaml
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

## **Configuring Dynamic Inventory**

To manage the infrastructure dynamically, I installed the required module and created an `aws_ec2.yaml` file:

```yaml
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

This configuration groups instances by the `instance` tag, resulting in two groups:
- **instance__db**
- **instance__web**

To verify instance grouping, I ran:

```sh
ansible-inventory -i aws_ec2.yaml --list
```

Example output:

```json
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

## **Playbook Configuration**

The main **playbook** includes all created roles:

```yaml
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

The playbook is executed using:

```sh
ansible-playbook playbook.yaml -i aws_ec2.yaml -u ubuntu --private-key=/root/.ssh/instance_test_key
```

---

## **Encrypting Sensitive Data with Ansible Vault**

To encrypt confidential data (e.g., passwords), I used:

```sh
ansible-vault create vault.yml
```

After entering a password, the **nano editor** opened, where I added:

```yaml
ansible_user: ubuntu
SuperData: Ansible_vault
```

To use encrypted variables in the playbook, I added:

```yaml
vars_files:
  - vault.yml
```

To test the encryption, I inserted the variable into a template:

```html
<h1>It works! {{ SuperData }}</h1>
```

I verified the result using `curl`:

```sh
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

## **Configuring Multiple Playbooks for Different Scenarios**

I created **two separate playbooks**:

### **First Playbook**
Includes **baseline**, **firewall**, and **nginx** roles:

```yaml
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

Execution:

```sh
ansible-playbook playbook.yaml -i aws_ec2.yaml -u ubuntu --private-key=/root/.ssh/instance_test_key --ask-vault-pass
```

Result:

![image](https://github.com/user-attachments/assets/d7f5a0c3-4ca6-4d97-b759-14f1dd2574cb)

---

### **Second Playbook**
Used only for **public instances**, including **baseline** and **firewall** roles:

```yaml
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

Execution:

```sh
ansible-playbook playbook_2.yaml -i aws_ec2.yaml -u ubuntu --private-key=/root/.ssh/instance_test_key
```

Result:

![image](https://github.com/user-attachments/assets/ff98b893-f9d7-4774-a44d-fb2a25eda518)