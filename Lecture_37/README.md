# AWS Lambda

## Підготовка DynamoDB

Для цього я створив таблицю `Lecture_37` з ключовим полем `userid`, а також іншими атрибутами, такими як:

- **email**
- **gender**
- **name**
- **surname**

Також додав тестового юзера:

![image](https://github.com/user-attachments/assets/213faf0a-b392-444b-bdda-33637f216f8b)

---

## Налаштування DynamoDB Streams

На сторінці моєї бази даних я увімкнув відповідну конфігурацію та налаштував, щоб вона спрацьовувала при створенні нових записів і оновленні існуючих у БД.

![Pasted image 20250203221152](https://github.com/user-attachments/assets/4c99e601-5e31-4c12-90e9-6aba5608f1b8)

---

## Створення Lambda-функції

Спочатку я створив роль з наступними політиками:

- **AmazonDynamoDBFullAccess**
- **AmazonSESFullAccess**

Після цього створив Lambda-функцію на Python та додав тригер DynamoDB, щоб вона спрацьовувала при зміні даних у таблиці.

---

## Налаштування Amazon SES

Я додав свою пошту до **Verified identities**, щоб мати змогу надсилати повідомлення.

---

## Написання коду Lambda-функції

Як працює функція:

- **Читає події з DynamoDB Streams**, реагуючи на нові або змінені записи.
- **Отримує email, ім'я, прізвище та стать користувача** з записів у DynamoDB.
- **Формує персоналізований вітальний лист** із змінними, отриманими через DynamoDB.
- **Надсилає email користувачеві**, вітаючи його в сервісі.

```python
import json
import boto3
  
ses_client = boto3.client('ses', region_name="us-east-1")
  
SENDER_EMAIL = "illlas70587@gmail.com"
  
def send_welcome_email(email, name, surname, gender):
    if gender and gender.lower() == "male":
        greeting = f"Mr. {surname}"
    elif gender and gender.lower() == "female":
        greeting = f"Ms. {surname}"
    else:
        greeting = name
  
    subject = f"Welcome to Service, {name}!"
    body_text = f"""
    Dear {greeting},
  
    Welcome to our service! 🎉 We are delighted to have you as a part of our community.
  
    We thank you for registering and hope you have a great experience using our platform.
  
    ✨ Follow us on social media and subscribe to our newsletter to receive the latest updates, exclusive offers, and insights.
  
    Best regards,
    Service
    """
  
    try:
        response = ses_client.send_email(
            Source=SENDER_EMAIL,
            Destination={"ToAddresses": [email]},
            Message={
                "Subject": {"Data": subject},
                "Body": {"Text": {"Data": body_text}},
            }
        )
        print(f"Email sent successfully to {email}!")
        return response
    except Exception as e:
        print(f"Error sending email to {email}")
        return None
  
def lambda_handler(event, context):    
    for record in event.get('Records', []):
        if record.get('eventName') in ['INSERT', 'MODIFY']:
            new_image = record['dynamodb'].get('NewImage', {})
  
            email = new_image.get('email', {}).get('S', None)
            name = new_image.get('name', {}).get('S', "User")
            surname = new_image.get('surname', {}).get('S', "")
            gender = new_image.get('gender', {}).get('S', "")
  
            if email and name:
                email_status = send_welcome_email(email, name, surname, gender)
  
                if email_status:
                    print(f"Email successfully sent to {email}")
                else:
                    print(f"Failed to send email to {email}")
            else:
                print("Missing email or name.")
  
    return {"status": "success"}
```

---

## Тестування

Для тестування цієї функції я додаю запис у **DynamoDB** з даними користувача, після чого Lambda надсилає лист.

![Pasted image 20250204000718](https://github.com/user-attachments/assets/7989d34c-9b54-4c69-bd51-3892233d34b4)

### Приклад листа:

![Pasted image 20250204001431](https://github.com/user-attachments/assets/82c42411-dfad-4bf2-8e61-83619cc8eefb)
