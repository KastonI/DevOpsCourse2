# AWS Basics
## Створення та налаштування VPC
### Створіть нову VPC

Пiд час створення VPC я використовував наступнi налаштування 
- Обрав опцiю : **VPC only**
- Дав назву для VPC : **Homework-22**
- Обрав CIDR-блок : **10.0.0.0/16**

![Pasted image 20241130202903](https://github.com/user-attachments/assets/fe9629aa-6b7e-474e-9b01-8429f98ca765)

### Далi у цьому VPC я створив пiдмережi:

Homework-subnet-public1:
- AZ : **us-east-1f**
- CIDR для пiдмережi: **10.0.1.0/24**

Homework-subnet-private1:
- AZ : **us-east-1f**
- CIDR для пiдмережi : **10.0.2.0/24**

![Pasted image 20241130204213](https://github.com/user-attachments/assets/695d2e3e-89d1-4538-aeb8-4e4c2413309e)

### Створіть та налаштуйте інтернет-шлюз (Internet Gateway)

Створення шлюзу

![Pasted image 20241130204348](https://github.com/user-attachments/assets/23e5615b-b24c-45b8-8bda-a7da1e50d780)

Додавання його до створеного VPC

![Pasted image 20241130204458](https://github.com/user-attachments/assets/17d1973e-cdcb-4f42-a9f3-07ad260a01db)

### Налаштування таблиць маршрутизацiї

Для цього я зайшов у налаштування таблиць маршрутизацiї i додав до них `Internet Gateway`.

![Pasted image 20241201010658](https://github.com/user-attachments/assets/5cff73f6-61c7-4a10-96e5-c0ab22dc20f6)

А також додав асоцiацiю Route tables з Public пiдмережею.

## Налаштування груп безпеки (Security Groups) та списків контролю доступу (ACL)
### Додайте правила для дозволу вхідного HTTP та SSH трафіку з будь-якої IP-адреси.

Для цього я зайшов у налаштування Security Group i додав правила для вхiдного трафiку HTTP i SSH.

![Pasted image 20241201012112](https://github.com/user-attachments/assets/5efdde0c-eedb-46aa-8ec8-7481e6ab48af)

## Запустіть новий інстанс EC2

Далi згiдно iнструкцiй у завданнi я створив EC2 iнстанс. А також для доступу створив SSH ключi.

У процессi створення я спецiльно не назначав публiчну ip адресу для того щоб створити її вручну.

Пiсля цих налаштувань, iнстанс створився i працював у публiчнiй пiдмережi.

![Pasted image 20241201013706](https://github.com/user-attachments/assets/f17a8ae1-de42-4aff-9503-d6d53edc7481)

Я спробував пiдключитися до iнстансу за допомогою `EC2 Instance Connect`, але виявилось що для цього необхiдна публiчна ip адреса. Тому я перейшов до наступного пункту.
## Призначення еластичної IP-адреси (EIP)

Для створення я зайшов у вiдповiдний блок меню i там створив Ip адресу, яку потiм асоцiював з необхiдним iнстансом(його мереживим iнтерфейсом). 

![Pasted image 20241201014417](https://github.com/user-attachments/assets/07df4368-068c-43b6-951d-a252a7335344)

Пiсля цих дiй я нарештi отримав доступ до свого запущеного iнстансу.

![Pasted image 20241201014649](https://github.com/user-attachments/assets/10be3c1d-8ec0-437a-b3fa-ff35b5a7ea3f)

Для перевiрки правильного налаштування Security Group, а саме доступу по SSH i HTTP, я спробував пiдключитись до iнстансу за допомогою SSH ключа. 

Все вийшло без проблем, а також пiсля цього я встановив `Nginx` i спробував вiдкрити його сторiнку з браузеру для перевiрки HTTP.

![Pasted image 20241201020031](https://github.com/user-attachments/assets/6f004693-2339-4c86-80d4-6c6bf12837fb)

### Видалення EC2 i всiх iнших залежних частин

1. Спочатку я видалив сам EC2 iнстанс
2. Вiд’єднав Internet Gateway вiд VPC
3. Видалив Internet Gateway
4. Вiдпустив Elastic IP
5. Видалив VPC i пов’язанi з ним сабнети
6. А також SSH ключ який залишився
