
# AWS DB Services

## Створення RDS інстансу

За допомогою веб-інтерфейсу я створив RDS PostgreSQL інстанс із налаштуваннями, вказаними у завданні, а також дозволив **public access**, щоб можна було підключитися до бази з комп'ютера.  
Це, звісно, дуже небезпечно, але налаштування **Security Group** на доступ лише з мого IP, а також надійний пароль трохи поліпшують ситуацію.

## Підключення до бази

Після цього я підключився до RDS за допомогою **DBeaver** і через його інтерфейс виконав SQL-скрипт, який створив таблиці з налаштуваннями.

## Створення бази даних та таблиць

Я трохи модифікував скрипт, який був поданий у завданні, для сумісності з **PostgreSQL**.

```
CREATE DATABASE library;

CREATE TABLE authors (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    country VARCHAR(255)
);

CREATE TABLE books (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author_id INT REFERENCES authors(id),
    genre VARCHAR(50)
);

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'reading_status_enum') THEN
        CREATE TYPE reading_status_enum AS ENUM ('reading', 'completed', 'planned');
    END IF;
END $$;

CREATE TABLE reading_status (
    id SERIAL PRIMARY KEY,
    book_id INT REFERENCES books(id),
    status reading_status_enum NOT NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Внесення даних

Для цього я використав подані у завданні запити, які виконувались через консоль SQL-скриптів.  
У другому `INSERT` виникла помилка через апостроф у назві `Harry Potter and the Philosophers Stone`, який зламав логіку запиту. У MySQL можна поставити зворотній слеш, але тут я просто прибрав його.

```
INSERT INTO authors (name, country) VALUES
    ('George Orwell', 'United Kingdom'),
    ('J.K. Rowling', 'United Kingdom'),
    ('Haruki Murakami', 'Japan');

INSERT INTO books (title, author_id, genre) VALUES
    ('1984', 1, 'Dystopian'),  -- George Orwell
    ('Harry Potter and the Philosophers Stone', 2, 'Fantasy'),
    ('Kafka on the Shore', 3, 'Magical realism');

INSERT INTO reading_status (book_id, status) VALUES
    (1, 'reading');
```

## Виконання запитів

### Запит для пошуку непрочитаних книг

```
SELECT books.title, authors.name 
FROM books
JOIN authors ON books.author_id = authors.id
LEFT JOIN reading_status ON books.id = reading_status.book_id
WHERE reading_status.status IS NULL OR reading_status.status != 'completed';
```

![Pasted image 20250127094229](https://github.com/user-attachments/assets/7806e21f-0258-42dc-9e69-b13dbdf013ab)

### Запит для підрахунку книг у статусі "reading"

```
SELECT COUNT(*) AS reading_books
FROM reading_status
WHERE status = 'reading';
```

![Pasted image 20250127094400](https://github.com/user-attachments/assets/f77fc016-bab1-4954-8ab6-e0c295b12db8)

## Налаштування доступу і створення нового користувача

Я використав такі команди, вказавши логін, IP-адресу та пароль:

```
CREATE USER 'library_user_illia'@'217.153.49.182' IDENTIFIED BY 'my_super_secret_password';

GRANT SELECT, INSERT, UPDATE ON library.* TO 'library_user_illia'@'217.153.49.182';
FLUSH PRIVILEGES;
```

Підключення до БД з нового користувача пройшло успішно.

## Моніторинг та резервне копіювання

Я ввімкнув автоматичні бекапи з **Backup retention period: 7 днів**.

![Pasted image 20250127105403](https://github.com/user-attachments/assets/f0ec3960-7aa8-4271-9013-3f892034377e)

Переглянув метрики інстансу в **CloudWatch**:

![Pasted image 20250127110346](https://github.com/user-attachments/assets/d25dbf8f-be57-4a02-9705-123d7a8a582d)

## Додаткове завдання

Враховуючи, що VPC, SG та все інше вже створено, додаємо лише інстанс бази даних.

```
aws rds create-db-instance \
    --db-instance-identifier library-db \
    --db-instance-class db.t4g.micro \
    --engine postgres \
    --allocated-storage 20 \
    --master-username admin1 \
    --master-user-password my_super_secret_password \
    --vpc-security-group-ids sg-01f2d2a309cf90fe7 \
    --backup-retention-period 7 \
    --db-subnet-group-name default-vpc-0a43cd3491911025f
```

![image](https://github.com/user-attachments/assets/93ca4795-80e3-41aa-81f0-428fb54dd5d6)
