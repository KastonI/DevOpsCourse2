# AWS CloudFormation

## Створення VPC

Для створення VPC необхідно було створити наступні ресурси:

- `VPC`
- `Public Subnet`
- `Internet Gateway`
- `Gateway Attachment`
- `Route Table`
- `Route`
- `Route Table Attachment`

### Налаштування **Public Subnet**

- `AvailabilityZone`: **"us-east-1a"**  
- `CidrBlock`: **"10.0.1.0/24"**  
- `MapPublicIpOnLaunch`: **true**  

### Налаштування **Route**

- `DestinationCidrBlock`: **0.0.0.0/0**

## Створення EC2 інстансу

Для створення EC2 необхідні наступні ресурси:

- `Role`
- `Instance Profile`
- `Instance`

### Роль

Для доступу до S3 бакету додано політику для читання:  
**arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess**

### Instance Profile

Цей профіль створений для того, щоб можна було приєднати роль до інстансу.

### Параметри інстансу

- `InstanceType`: **t2.micro**  
- `ImageId`: **ami-0852de09092f3a061**  
- `SubnetId`: **!Ref Public**  
- `IamInstanceProfile`: **!Ref InstanceProfile**  
- `KeyName`: **instance_test_key**

## Створення S3 Bucket

### Параметри бакету

- `BucketName`: **backet-2394i23j**  
- `VersioningConfiguration:`  
  - `Status`: **Enabled**

## Outputs

```
InstancePublicIP:
  Value: !GetAtt MyEC2Instance.PublicIp
  Description: Public IP of the EC2.

BucketName:
  Value: !Ref MyS3Bucket
  Description: Name of S3 Bucket.
```

## Прийняття змін

Для того, щоб використати цей `template`, я виконав команду:

```
aws cloudformation create-stack \
  --stack-name MyStackName \
  --template-body file://VPC.yaml \
  --capabilities CAPABILITY_NAMED_IAM
```

### Перевірка Outputs

Для перевірки `outputs` можна використати наступну команду:

```
aws cloudformation describe-stacks \
  --stack-name MyStackName \
  --query "Stacks[0].Outputs"
```

### Видалення Stack

```
aws cloudformation delete-stack --stack-name MyStackName
```

## Drift Detection

Я вручну видалив інстанс та запустив **drift detection**.

### Виявлення змін

Для пошуку змін я використав **AWS Console**.  

![Pasted image 20250128043005](https://github.com/user-attachments/assets/01b58946-e0e5-4286-a849-075a469e6b23)

Ось тут видно, що зміни були виявлені:

![Pasted image 20250128043100](https://github.com/user-attachments/assets/0b6ae175-3934-4487-b64f-092e9ab21232)
