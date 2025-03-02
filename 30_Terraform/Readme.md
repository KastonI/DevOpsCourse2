# **Advanced Terraform**

## **Creating a VPC with Two Servers in Public and Private Subnets Using Terraform Modules**

To complete this task, I divided the infrastructure into the following **modules**:

### **Module [VPC](terraform_modules/modules/vpc/main.tf)**

- `vpc`
- `private_subnet`
- `public_subnet`

### **Module [Routes and Connections](terraform_modules/modules/routes_and_connections/main.tf)**

- `internet_gw`
- `nat_gw`
- `eip_nat`
- `sg` (ingress/egress)
- `private_subnet_rt`
- `public_subnet_rt`
- `private_subnet_association`
- `public_subnet_association`

### **Module [EC2](terraform_modules/modules/ec2/main.tf)**

- `private_instance`
- `public_instance`

![Pasted image 20250120223656](https://github.com/user-attachments/assets/e2a4434a-2cf3-421f-84b4-79032a46aba6)

---

## **VPC Module**

### **Input Variables:**
- `vpc_cidr`
- `public_subnet_cidr`
- `private_subnet_cidr`
- `az_zone`

### **Outputs:**
- `vpc_id`
- `private_subnet_id`
- `public_subnet_id`

### **Subnet Configuration:**
- **Public Subnet**:  
  ```hcl
  map_public_ip_on_launch = true
  ```
- **Private Subnet**:  
  ```hcl
  map_public_ip_on_launch = false
  ```

---

## **Routes and Connections Module**

### **Input Variables:**
- `vpc_id` (from **VPC module**)
- `public_subnet_id` (from **VPC module**)
- `private_subnet_id` (from **VPC module**)
- `public_subnet_cidr` (from **variables** file)
- `private_subnet_cidr` (from **variables** file)

### **Outputs:**
- `nat_ip`
- `sg_id`

### **Details:**
- Most resources are linked through **IDs**.
- **Private subnet traffic** is routed through **NAT Gateway**.
- **Public subnet traffic** is routed through **Internet Gateway**.
- **Security Group Configuration:**
  - **Inbound Traffic**: Only **SSH** and **HTTP** allowed.
  - **Outbound Traffic**: All protocols allowed.

---

## **EC2 Module**

### **Input Variables:**
- `ami_id` (from **variables** file)
- `key_name` (from **variables** file)
- `instance_type` (from **variables** file)
- `public_subnet_id` (from **Routes and Connections module**)
- `private_subnet_id` (from **Routes and Connections module**)
- `public_instance_count` (from **variables** file)
- `private_instance_count` (from **variables** file)
- `sg_id` (from **Routes and Connections module**)

### **Outputs:**
- `private_instance_private_ips`
- `public_instance_private_ips`

### **Description:**
This module creates **EC2 instances** in both **public** and **private** subnets.

---

## **Main Configuration File**

The **`main.tf`** file defines:
- **Modules** and their input variables.
- **Backend configuration** for an **S3 bucket**, so that the **Terraform state file** (`.tfstate`) is stored remotely instead of locally.

After defining everything, I executed:

```sh
terraform apply
```

✅ **Terraform applied successfully**  
![Pasted image 20250120233658](https://github.com/user-attachments/assets/9d2e0ff8-9af6-4a8a-bebe-97db391378c5)

---

## **Importing Existing Resources into Terraform Configuration**

### **Process Description:**
1. **Created a standard Terraform file** to define the [VPC](terraform_import/main.tf).
2. **Manually created an EC2 instance** in AWS.
3. **Imported the existing instance into the Terraform state** using:

```sh
terraform import aws_instance.public_instance i-0913d9b5cc2a77086
```

4. **Verified the imported instance** using:

```sh
terraform state list
terraform state show aws_instance.public_instance
```

5. **Added the imported resource to the Terraform configuration**.

### **Issue Resolution:**
After verification, multiple **errors** appeared.  
- **Unnecessary data** was either **removed** or **replaced with variables**.  
- After making adjustments, the instance was successfully created.