# **AWS CloudFormation - Infrastructure as Code (IaC)** 🚀  

---

## **1️⃣ Creating a VPC**
To deploy an **AWS Virtual Private Cloud (VPC)**, I needed to define the following **CloudFormation resources**:

### **VPC Configuration**
- **Public Subnet** (`Public`)
- **Internet Gateway** (`IGW`)
- **Gateway Attachment** (`AttachIGW`)
- **Route Table** (`RouteTable`)
- **Route** (`DefaultRoute`)
- **Route Table Association** (`RouteTableAssociation`)

---

### **2️⃣ Configuring a Public Subnet**
✅ **Subnet Settings:**
- **Availability Zone:** `"us-east-1a"`
- **CIDR Block:** `"10.0.1.0/24"`
- **Public IP Auto-Assignment:** `true`

---

### **3️⃣ Creating EC2 Instance**
To deploy an **EC2 instance**, I needed the following resources:

- **IAM Role** (`EC2Role`)
- **Instance Profile** (`InstanceProfile`)
- **EC2 Instance** (`MyEC2Instance`)

---

### **4️⃣ Configuring IAM Role**
To **grant EC2 access to S3**, I attached the **AmazonS3ReadOnlyAccess** policy:

```yaml
Policies:
  - PolicyName: S3ReadOnlyAccess
    PolicyDocument:
      Version: "2012-10-17"
      Statement:
        - Effect: Allow
          Action: "s3:ListBucket"
          Resource: "*"
```

---

### **5️⃣ Instance Configuration**
✅ **EC2 Instance Parameters:**
- **Instance Type:** `t2.micro`
- **AMI ID:** `ami-0852de09092f3a061`
- **Subnet ID:** `!Ref Public`
- **IAM Instance Profile:** `!Ref InstanceProfile`
- **Key Pair Name:** `"instance_test_key"`

---

## **6️⃣ Creating an S3 Bucket**
✅ **S3 Bucket Configuration:**
- **Bucket Name:** `backet-2394i23j`
- **Versioning Enabled:** ✅

```yaml
Resources:
  MyS3Bucket:
    Type: "AWS::S3::Bucket"
    Properties:
      BucketName: "backet-2394i23j"
      VersioningConfiguration:
        Status: "Enabled"
```

---

## **7️⃣ Defining CloudFormation Outputs**
To display the **EC2 Public IP and S3 Bucket Name**, I added the following **Outputs**:

```yaml
Outputs:
  InstancePublicIP:
    Value: !GetAtt MyEC2Instance.PublicIp
    Description: Public IP of the EC2.

  BucketName:
    Value: !Ref MyS3Bucket
    Description: Name of S3 Bucket.
```

---

## **8️⃣ Deploying CloudFormation Stack**
To **apply the CloudFormation template**, I used:

```sh
aws cloudformation create-stack \
  --stack-name MyStackName \
  --template-body file://VPC.yaml \
  --capabilities CAPABILITY_NAMED_IAM
```

---

## **9️⃣ Verifying CloudFormation Outputs**
To check the **deployed stack outputs**, I used:

```sh
aws cloudformation describe-stacks \
  --stack-name MyStackName \
  --query "Stacks[0].Outputs"
```

---

## **🔟 Deleting the CloudFormation Stack**
To **delete all created resources**, I ran:

```sh
aws cloudformation delete-stack --stack-name MyStackName
```

---

## **1️⃣1️⃣ Drift Detection (Tracking Infrastructure Changes)**
### **1. Manual Change:**  
I **deleted the EC2 instance** manually from the **AWS Console**.

### **2. Running Drift Detection**
I used the **AWS Console** to detect changes in the stack.

✅ **Drift Detected:**  
![Pasted image 20250128043005](https://github.com/user-attachments/assets/01b58946-e0e5-4286-a849-075a469e6b23)

✅ **Stack Drift Details:**  
![Pasted image 20250128043100](https://github.com/user-attachments/assets/0b6ae175-3934-4487-b64f-092e9ab21232)