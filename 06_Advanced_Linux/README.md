# **Homework on the Topic "Advanced Linux"**


## **1. Install and Configure the Nginx Web Server from the Official Repository**
First, update the package list and install `Nginx`:

```sh
apt update && apt upgrade
apt install nginx -y
```

To check if `Nginx` is installed correctly, run:

```sh
systemctl status nginx
```

---

## **2. Add and Remove a PPA Repository for Nginx, Then Revert to the Official Version Using `ppa-purge`**
I followed the **official Nginx installation guide**.

First, install necessary dependencies:

```sh
apt install curl gnupg2 ca-certificates lsb-release debian-archive-keyring
```

Then, **import the official signing key**:

```sh
curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
    | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
```

Verify the imported key:

```sh
gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg
```

Add the **official Nginx repository**:

```sh
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
http://nginx.org/packages/mainline/debian `lsb_release -cs` nginx" \
    | sudo tee /etc/apt/sources.list.d/nginx.list
```

Ensure the system prefers **Nginx packages** from this repository:

```sh
echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" \
    | sudo tee /etc/apt/preferences.d/99nginx
```

### **Reverting to the Stable Version**
To remove the custom repository, open the configuration file:

```sh
nano /etc/apt/sources.list.d/nginx.list
```
Delete the repository URL and **update the package list**:

```sh
apt update
```

Then, remove the existing version and reinstall the **stable** one:

```sh
apt remove nginx nginx-common
apt install nginx
```

Check the installed version:

```sh
nginx -V
```

---

## **3. Create and Configure a Custom `systemd` Service**
### **Step 1: Create a Script**
Using `nano`, I created a script named `date_and_time.sh`:

```sh
#!/bin/bash
echo "Current Date & Time: $(date +"%Y-%m-%d %H:%M:%S")" >> /var/log/date_and_time.log
```

Give it execution permissions:

```sh
chmod +x /opt/date_and_time.sh
```

Test the script manually:

```sh
./opt/date_and_time.sh
cat /var/log/date_and_time.log
```

---

### **Step 2: Create a `systemd` Service**
Create a new service file:

```sh
nano /etc/systemd/system/date_and_time.service
```

Add the following content:

```ini
[Unit]
Description=Date and Time Logging Service

[Service]
ExecStart=/opt/date_and_time.sh

[Install]
WantedBy=multi-user.target
```

Reload the `systemd` daemon and start the service:

```sh
systemctl daemon-reload
systemctl start date_and_time.service
cat /var/log/date_and_time.log
```

---

### **Step 3: Create a Timer to Run the Script Every Minute**
Create a timer file:

```sh
nano /etc/systemd/system/date_and_time.timer
```

Add the following:

```ini
[Unit]
Description=Timer for Date Logging

[Timer]
OnBootSec=0sec
OnUnitActiveSec=1min
AccuracySec=1s
Unit=date_and_time.service

[Install]
WantedBy=timers.target
```

Reload the `systemd` configuration and start the timer:

```sh
systemctl daemon-reload
systemctl start date_and_time.timer
systemctl enable date_and_time.timer
tail -f /var/log/date_and_time.log
```

Now, the script **writes the current date and time to the log file every minute**.

![date_and_time](https://github.com/user-attachments/assets/a5d171a7-d927-4e87-a962-ee0c27e145ce)

---

## **4. Configure a Firewall Using `UFW`**
### **Installing UFW**
```sh
apt install ufw
```

By default, `UFW` is disabled, **allowing all outbound traffic and blocking all inbound traffic**.

### **Allow SSH Access from One IP and Deny It from Another**
```sh
ufw allow from 192.168.1.88 to any port 22
ufw deny from 192.168.1.11 to any port 22
```

Enable `UFW` and check the status:

```sh
ufw enable
ufw status
```

---

## **5. Set Up `Fail2Ban` to Protect Against Brute-Force Attacks on SSH**
### **Install Fail2Ban**
```sh
apt install fail2ban
```

### **Edit the Configuration File**
Copy the default configuration:

```sh
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
nano /etc/fail2ban/jail.local
```

Modify these parameters:

```ini
bantime = 1h
findtime = 10m
maxretry = 5
```

Enable SSH protection by modifying the `[sshd]` section:

```ini
enabled = true
port = 22
logpath = /var/log/auth.log
```

### **Restart `Fail2Ban` and Verify Its Status**
```sh
touch /var/log/auth.log
systemctl restart fail2ban.service
fail2ban-client status
```

---

## **6. Create and Mount a New Partition, Configure Auto-Mounting**
### **Step 1: Insert and Identify a New Storage Device**
Inserted a **USB drive** without a file system.

![/dev/sdb](https://github.com/user-attachments/assets/440b95b9-bc7f-47a7-9db6-377d6a6830b8)

### **Step 2: Create a New Partition Using `fdisk`**
```sh
sudo fdisk /dev/sdb
```

Then, format it to **ext4**:

```sh
mkfs.ext4 /dev/sdb1
```

### **Step 3: Mount the Partition**
Created a mount directory and mounted the disk:

```sh
mkdir /home/illia/files
mount /dev/sdb1 /home/illia/files
```

![Before reboot](https://github.com/user-attachments/assets/3560b089-ecae-41ce-a7e1-ee61ff0315a2)

---

### **Step 4: Enable Automatic Mounting on Boot**
To make the mount persistent, edit `/etc/fstab`:

```sh
nano /etc/fstab
```

Add the following line:

```ini
UUID=2e58d914-e095-47a0-bd87-06f3f667120c /home/illia/files ext4 defaults 0 1
```

Reboot the system and verify that the partition remains mounted.

![After reboot](https://github.com/user-attachments/assets/3aa572b0-cdca-4b93-bcdc-1014aebf72e2)
