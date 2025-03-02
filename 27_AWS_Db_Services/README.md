# **AWS RDS - Database Services on AWS** 🌐  

---

## **1️⃣ Creating an RDS Instance**
I created an **RDS PostgreSQL instance** using the **AWS Web Interface** with the following settings:
- **Engine:** PostgreSQL
- **Public Access:** Enabled (for external connection)
- **Security Group:** Limited to my **IP address**
- **Backup Retention Period:** 7 days

✅ **Security Considerations:**  
Although **public access is risky**, I mitigated it by:
1. **Restricting access to my IP**
2. **Using a strong password**

---

## **2️⃣ Connecting to the Database**
I connected to **RDS PostgreSQL** using **DBeaver** and ran the SQL script to **create tables**.

---

## **3️⃣ Creating the Database & Tables**
I slightly **modified** the provided script for **PostgreSQL compatibility**.

```sql
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

✅ **Database & Tables Successfully Created**

---

## **4️⃣ Inserting Data**
I executed the provided `INSERT` statements via SQL.

📌 **Issue:**  
- **Apostrophe in "Philosopher's Stone"** broke the query.  
- **Fix:** Removed or **escaped** the apostrophe.

```sql
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

✅ **Data Successfully Inserted**

---

## **5️⃣ Running Queries**
### **1. Query: Find Unread Books**
```sql
SELECT books.title, authors.name 
FROM books
JOIN authors ON books.author_id = authors.id
LEFT JOIN reading_status ON books.id = reading_status.book_id
WHERE reading_status.status IS NULL OR reading_status.status != 'completed';
```

✅ **Query Output:**
![Pasted image 20250127094229](https://github.com/user-attachments/assets/7806e21f-0258-42dc-9e69-b13dbdf013ab)

---

### **2. Query: Count Books in "Reading" Status**
```sql
SELECT COUNT(*) AS reading_books
FROM reading_status
WHERE status = 'reading';
```

✅ **Query Output:**
![Pasted image 20250127094400](https://github.com/user-attachments/assets/f77fc016-bab1-4954-8ab6-e0c295b12db8)

---

## **6️⃣ Configuring Access & Creating a New User**
### **Creating a New User with Limited Permissions**
```sql
CREATE USER 'library_user_illia'@'217.153.49.182' IDENTIFIED BY 'my_super_secret_password';

GRANT SELECT, INSERT, UPDATE ON library.* TO 'library_user_illia'@'217.153.49.182';
FLUSH PRIVILEGES;
```

✅ **Connected to RDS as the New User Successfully**

---

## **7️⃣ Monitoring & Backup Configuration**
### **1. Enabled Automatic Backups**
- **Backup Retention Period:** `7 days`

✅ **AWS Backup Configuration**
![Pasted image 20250127105403](https://github.com/user-attachments/assets/f0ec3960-7aa8-4271-9013-3f892034377e)

---

### **2. Checked Performance in AWS CloudWatch**
✅ **AWS CloudWatch Metrics**
![Pasted image 20250127110346](https://github.com/user-attachments/assets/d25dbf8f-be57-4a02-9705-123d7a8a582d)

---

## **8️⃣ Additional Task: Creating RDS via CLI**
Since **VPC, Security Groups, and Subnets** were already set up, I created only the **RDS instance**.

```sh
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

✅ **Successfully Created the RDS Instance**
![image](https://github.com/user-attachments/assets/93ca4795-80e3-41aa-81f0-428fb54dd5d6)