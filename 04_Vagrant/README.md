### **VM1 (Public Web Server):**
- **Host-name**: `Public-server`
- **Box file**: `bento/ubuntu-24.04`
- **Shared folder**: `./sync_folder`
- **Port forwarding** (for Nginx installation): `guest: 80, host: 8080`

#### **Provisioning Commands:**
- `apt-get update` and `apt-get upgrade` – update packages
- `apt-get install -y nginx` – install Nginx
- `sudo cp /vagrant_sync_folder/index.html /var/www/html` – copy the HTML file from the shared folder to Nginx
- `sudo systemctl restart nginx` – restart Nginx to apply changes

During testing and viewing the website with Vagrant, I realized that instead of copying the file, it would be better to create a **symlink** in the shared folder. This would make updating the page easier. However, I decided to keep the current approach but note that using a symlink is also an option.

---

### **VM2 (Private Server):**
- **Host-name**: `private-server`
- **Box file**: `bento/ubuntu-24.04`
- **Shared folder**: `./sync_folder`
- **Static IP**: `192.168.100.38`

#### **Provisioning Commands:**
- `apt-get update` and `apt-get upgrade` – update packages
- `echo "Update completed!"` – simple echo command

---

### **VM3 (Public Server with Static IP):**
- **Host-name**: `private-server`
- **Box file**: `bento/ubuntu-24.04`
- **Shared folder**: `./server`
- **Static IP**: `192.168.100.39`
- **Bridge Network Adapter**: `MediaTek Wi-Fi 6/6E Wireless USB LAN Card`

---

### **Additional Task**
I added two **global variables**:
- `num_of_machines = 3` – defines the number of virtual machines
- `first_ip = 11` – starting IP address for VMs

To create multiple machines, I used an **iterator**:
```ruby
(1..num_of_machines).each do |num|
```
(I found this method on the **Vagrant website**.)

Inside the shared folder (`sync_folder`), a **separate folder** is created for each machine:
```ruby
folder_machine = "./sync_folder/Virtual-machine#{num}"
FileUtils::mkdir_p folder_machine
```
When setting up virtual machines, I used **`#{num}`** in names, IPs, hostnames, and provisioning to differentiate them.

The **`folder_machine`** variable stores the path to the folder created specifically for the machine:
```ruby
vm.vm.synced_folder folder_machine, "/vagrant_sync_folder"
```
At the end of provisioning, the VM executes:
```sh
echo hello from VM#{num}
```