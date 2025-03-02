# **Homework on the Topic "SQL"**  

## **Creating the Database: Create a database named `SchoolDB`.**  
To create the database, I added the following commands to the script:  

```
CREATE DATABASE IF NOT EXISTS SchoolDB;
USE SchoolDB;
```

---

### **Table `Institutions`: Create the `Institutions` table**  
When creating the **Institutions** table, I used the following data types:  
- **INT AUTO_INCREMENT** – for automatic ID generation  
- **VARCHAR()** – for regular text fields  
- **ENUM()** – to restrict possible values and ensure data integrity  

```
institution_id INT AUTO_INCREMENT PRIMARY KEY,
institution_name VARCHAR(100) NOT NULL,
institution_type ENUM('School','Kindergarten') NOT NULL,
address VARCHAR(150) NOT NULL
```

---

### **Table `Classes`: Create the `Classes` table**  
When creating the **Classes** table, I used the following new data types:  
- **INT** – to reference a key and link tables together  

```
class_id INT AUTO_INCREMENT PRIMARY KEY,
class_name VARCHAR(50) NOT NULL,
institution_id INT,
institutions_direction ENUM('Mathematics', 'Biology and Chemistry', 'Language Studies') NOT NULL,
FOREIGN KEY (institution_id) REFERENCES institutions(institution_id)
```

---

### **Table `Children`: Create the `Children` table**  
When creating the **Children** table, I used the following new data types:  
- **DATE** – for birth date  
- **YEAR** – for the year of entry  
- **DECIMAL(10,2)** – for tuition fee values  

```
child_id INT AUTO_INCREMENT PRIMARY KEY,
first_name VARCHAR(50) NOT NULL,
last_name VARCHAR(50) NOT NULL,
birth_date DATE NOT NULL,
year_of_entry YEAR NOT NULL,
age INT NOT NULL,
tuition_fee DECIMAL(10,2) NOT NULL,
institution_id INT,
class_id INT,
FOREIGN KEY (institution_id) REFERENCES institutions(institution_id),
FOREIGN KEY (class_id) REFERENCES classes(class_id)
```

---

### **Table `Parents`: Create the `Parents` table**  
When creating the **Parents** table, I used the following data types:  

```
parent_id INT AUTO_INCREMENT PRIMARY KEY,
first_name VARCHAR(50) NOT NULL,
last_name VARCHAR(50) NOT NULL,
child_id INT,
FOREIGN KEY (child_id) REFERENCES children(child_id) 
```

After creating the tables, I obtained a database with the following structure:  

![image](https://github.com/user-attachments/assets/a09d3fd4-86f3-45c1-a7e7-3a9542a7ea58)  

---

### **Data Operations: Insert at least 3 records**  
**Done!**  
This can be seen in the `SchoolDB.sql` file.  

The ready script was executed using the following command and verified:  

```
mysql < SchoolDB.sql
mysql
show schemas;
```

It deployed successfully.  

---

## **Queries:**  

For the first task, I used the following query:  

```
SELECT child_id, first_name, last_name, institution_name, institutions_direction
FROM children 
JOIN institutions ON children.institution_id = institutions.institution_id
JOIN classes ON children.class_id = classes.class_id;
```

For the query **"Retrieve information about parents and their children along with the tuition fee,"** I used the following SQL query:  

```
SELECT children.child_id, children.first_name, children.last_name,
       age, parents.first_name AS parent_first_name,
       parents.last_name AS parent_last_name, tuition_fee 
FROM children
JOIN parents ON children.child_id = parents.child_id;
```

While writing this query, I encountered an issue where the names of children and parents had identical column names. I had to use the alias **`AS`** to rename `parents.first_name` and `parents.last_name`.  

For the query **"Retrieve a list of all institutions with addresses and the number of children studying in each institution,"** I used the following SQL query:  

```
SELECT institution_name, institutions.address, COUNT(children.child_id) AS children_count
FROM institutions 
JOIN children ON institutions.institution_id = children.institution_id
GROUP BY institutions.institution_name, institutions.address\G;
```

Here, to count the number of students, I used the `COUNT()` function, and for grouping, the SQL `GROUP BY` operator.  

---

## **Create a Backup of the Database, Restore It to a New Database, and Verify**  

Using the command:  

```
mysqldump schooldb > schooldb_backup.sql
```

I created a backup. Then, I deleted the existing database:  

```
DROP DATABASE schooldb;
```

I created the database again and restored it from the backup:  

```
CREATE DATABASE schooldb_backup;
mysql schooldb_backup < /home/illia/schooldb_backup.sql
```

To verify, I used one of the queries written above. It executed successfully and returned the same result.  

---

# **Additional Task: Data Anonymization**  

### **Anonymizing the `Children` Table:**  
To anonymize the fields **`first_name, last_name, tuition_fee`** in the `children` table, I used the following SQL query:  

```
UPDATE children 
SET first_name = 'Child',
    last_name = 'Anonymous',
    tuition_fee = ROUND(RAND() * (6000 - 3000) + 3000, 2);
```

As a result, I obtained an **anonymized `children` table**.  

---

### **Anonymizing the `Parents` Table:**  
To anonymize the fields **`first_name, last_name`** in the `parents` table, I used the following SQL query:  

```
SET @counter = 0;
UPDATE parents
SET first_name = CONCAT('Parent', @counter := @counter + 1),
    last_name = 'Anonymous';
```

As a result, I obtained an **anonymized `parents` table**.  

---

### **Anonymizing the `Institutions` Table:**  
To anonymize the fields **`institution_name, address`** in the `institutions` table, I used the following SQL query:  

```
SET @counter = 0;
UPDATE institutions
SET institution_name = CONCAT('Institution', @counter := @counter + 1),
    address = CONCAT('Address', @counter);
```

As a result, I obtained an **anonymized `institutions` table**.