# Advanced Terraform

## Створення VPC з двома серверами у публічній та приватній підмережах за допомогою Terraform, застосовуючи модулі

Для виконання цього завдання я вирішив розділити створення інфраструктури на такі модулі:

### Модуль [VPC](terraform_modules/modules/vpc/main.tf)

- `vpc`
- `private_subnet`
- `public_subnet`

### Модуль **Routes and Connections** [Routes and Connections](terraform_modules/modules/routes_and_connections/main.tf)

- `internet_gw`
- `nat_gw`
- `eip_nat`
- `sg` (ingress/egress)
- `private_subnet_rt`
- `public_subnet_rt`
- `private_subnet_association`
- `public_subnet_association`

### Модуль [EC2](terraform_modules/modules/ec2/main.tf)

- `private_instance`
- `public_instance`

![Pasted image 20250120223656](https://github.com/user-attachments/assets/e2a4434a-2cf3-421f-84b4-79032a46aba6)

## Модуль **VPC**

У цей модуль я передаю такі **змінні**:

- `vpc_cidr`
- `public_subnet_cidr`
- `private_subnet_cidr`
- `az_zone`

**Вивідні дані** цього модуля:

- `vpc_id`
- `private_subnet_id`
- `public_subnet_id`

Налаштування для підмереж:
**Для публічної** :

	map_public_ip_on_launch = true

**Для приватної** :

	map_public_ip_on_launch = false


## Модуль **Routes and Connections**

### Змінні для цього модуля:

- `vpc_id` — отримується з модуля **VPC**
- `public_subnet_id` — отримується з модуля **VPC**
- `private_subnet_id` — отримується з модуля **VPC**
- `public_subnet_cidr` — береться з файлу **variables**
- `private_subnet_cidr` — береться з файлу **variables**

### Вивідні дані цього модуля:

- `nat_ip`
- `sg_id`

#### Деталі:

- Більшість ресурсів пов'язані між собою за допомогою **ID**.
- Трафік із приватної підмережі йде через **NAT Gateway**, а з публічної підмережі — через **Internet Gateway**.
- У **Security Group**:
    - Дозволено вхідний трафік лише для **SSH** і **HTTP**.
    - Вихідний трафік дозволений для всіх протоколів.

## Модуль **EC2**

### Вхідні змінні:

- `ami_id` — з файлу **variables**
- `key_name` — з файлу **variables**
- `instance_type` — з файлу **variables**
- `public_subnet_id` — з модуля **Routes and Connections**
- `private_subnet_id` — з модуля **Routes and Connections**
- `public_instance_count` — з файлу **variables**
- `private_instance_count` — з файлу **variables**
- `sg_id` — з модуля **Routes and Connections**

### Вивідні дані:

- `private_instance_private_ips`
- `public_instance_private_ips`

#### Опис:

У цьому модулі створюються EC2 інстанси у публічній та приватній підмережах.

## Основний файл конфігурації

У файлі `main.tf` визначено модулі, які використовуються, а також змінні, що передаються із головного файлу до файлів модулів.

Також у цьому файлі налаштовано **backend** для S3-бакета, щоб файл `.tfstate` зберігався не локально, а у S3.

Пiсля цього я запустив команду 

	terraform apply

![Pasted image 20250120233658](https://github.com/user-attachments/assets/9d2e0ff8-9af6-4a8a-bebe-97db391378c5)

## Імпорт наявних ресурсів у Terraform-конфігурацію

### Опис процесу:

1. Я створив стандартний Terraform файл для створення всіх частин [vpc](terraform_import/main.tf).
2. Вручну створив EC2 інстанс.
3. Використав команду для імпорту ресурсу у state файл:

`terraform import aws_instance.public_instance i-0913d9b5cc2a77086`
 
4. Перевірив, чи інстанс імпортовано, і вивів його інформацію:

`terraform state list`
`terraform state show aws_instance.public_instance`
 
5. Додав ресурс у конфігураційний файл Terraform.

Пiсля виконання перевiрки вилiзло дуже багато помилок, непотрiбнi даннi я або видалив, або замiнив змiнними. Після цього інстанс створився успішно.
