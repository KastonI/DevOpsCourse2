# **AWS Basics - VPC, EC2, and Networking** 🌐  

---

## **1️⃣ Creating and Configuring a VPC**
### **1. Creating a New VPC**
During the VPC creation, I used the following settings:
- **VPC Type:** `VPC only`
- **VPC Name:** `Homework-22`
- **CIDR Block:** `10.0.0.0/16`

✅ **Result:**
![Pasted image 20241130202903](https://github.com/user-attachments/assets/fe9629aa-6b7e-474e-9b01-8429f98ca765)

---

### **2. Creating Subnets in the VPC**
I created **two subnets** in the **same availability zone** (`us-east-1f`).

#### **Public Subnet** (`Homework-subnet-public1`)
- **Availability Zone:** `us-east-1f`
- **CIDR Block:** `10.0.1.0/24`

#### **Private Subnet** (`Homework-subnet-private1`)
- **Availability Zone:** `us-east-1f`
- **CIDR Block:** `10.0.2.0/24`

✅ **Result:**
![Pasted image 20241130204213](https://github.com/user-attachments/assets/695d2e3e-89d1-4538-aeb8-4e4c2413309e)

---

### **3. Creating and Attaching an Internet Gateway**
I created a **new Internet Gateway (IGW)** and **attached it to the VPC**.

✅ **Internet Gateway Created:**
![Pasted image 20241130204348](https://github.com/user-attachments/assets/23e5615b-b24c-45b8-8bda-a7da1e50d780)

✅ **IGW Attached to VPC:**
![Pasted image 20241130204458](https://github.com/user-attachments/assets/17d1973e-cdcb-4f42-a9f3-07ad260a01db)

---

### **4. Configuring Route Tables**
To **allow public internet access**, I **modified the route table** and **added the Internet Gateway**.

✅ **Route Table Configuration:**
![Pasted image 20241201010658](https://github.com/user-attachments/assets/5cff73f6-61c7-4a10-96e5-c0ab22dc20f6)

✅ **Associated the Public Subnet with the Route Table.**

---

## **2️⃣ Configuring Security Groups and ACLs**
### **Adding Inbound Rules for SSH and HTTP Traffic**
To allow **SSH (port 22) and HTTP (port 80)**, I updated the **Security Group** rules.

✅ **Security Group Rules:**
![Pasted image 20241201012112](https://github.com/user-attachments/assets/5efdde0c-eedb-46aa-8ec8-7481e6ab48af)

---

## **3️⃣ Launching an EC2 Instance**
Following the **instructions**, I launched an **EC2 instance** in the **public subnet**.

🔹 **Created SSH Key Pair** for access.  
🔹 **Did NOT assign a public IP initially** (to configure it manually later).  

✅ **EC2 Instance Created:**
![Pasted image 20241201013706](https://github.com/user-attachments/assets/f17a8ae1-de42-4aff-9503-d6d53edc7481)

---

### **❌ Issue: No Public IP for EC2 Instance**
I attempted to connect using **EC2 Instance Connect**, but **it requires a public IP**.  
Since **no public IP was assigned**, I moved to the next step.

---

## **4️⃣ Assigning an Elastic IP (EIP)**
To **manually assign a public IP**, I:
1. **Created a new Elastic IP**
2. **Associated it with the EC2 instance**

✅ **Elastic IP Assigned:**
![Pasted image 20241201014417](https://github.com/user-attachments/assets/07df4368-068c-43b6-951d-a252a7335344)

✅ **Now I could access my EC2 instance!**
![Pasted image 20241201014649](https://github.com/user-attachments/assets/10be3c1d-8ec0-437a-b3fa-ff35b5a7ea3f)

---

## **5️⃣ Verifying Security Group Rules**
To test:
- **SSH Access** via Key Pair  
- **HTTP Access** via Nginx  

✅ **SSH Connection Worked**
✅ **Installed Nginx & Tested HTTP Access**

![Pasted image 20241201020031](https://github.com/user-attachments/assets/6f004693-2339-4c86-80d4-6c6bf12837fb)

---

## **6️⃣ Deleting Resources**
To **avoid extra charges**, I cleaned up **all resources**:
1. **Deleted the EC2 Instance** 🗑️  
2. **Detached and Deleted the Internet Gateway**  
3. **Released the Elastic IP**  
4. **Deleted the VPC and Subnets**  
5. **Removed the SSH Key Pair**  