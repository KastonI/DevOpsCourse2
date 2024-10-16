# Домашнє завдання з теми "SQL"

Для створення бази данних, її структури i внесення даних я вирiшив використати скрипт.
## Створення бази даних: Створіть базу даних з назвою SchoolDB.
Для створення БД у скрипт я додав наступнi команди.

```
CREATE DATABASE IF NOT EXISTS SchoolDB;
USE SchoolDB;
```

### Таблиця Institutions: Створіть таблицю Institutions

При створеннi таблицi **Institutions**, я використав наступнi типи данних.
- **INT AUTO_INCREMENT** - для автоматичної генерацiї iдентифiкаторiв
- **VARCHAR()** -  для звичайних текстових полiв
- **ENUM()** - щоб обмежити можливі значення, i забезпечити цiлiстнiсть даних.

```
institution_id INT AUTO_INCREMENT PRIMARY KEY,
institution_name VARCHAR(100) NOT NULL,
institution_type ENUM('School','Kindergarten') NOT NULL,
address VARCHAR(150) NOT NULL
```

### Таблиця Classes: Створіть таблицю Classes

При створеннi таблицi **Classes**, я використав такi новi типи даних.
- **INT** - для посилання на ключ, щоб звязати таблицi мiж собою

```
class_id INT AUTO_INCREMENT PRIMARY KEY,
class_name VARCHAR(50) NOT NULL,
institution_id INT,
institutions_direction ENUM('Mathematics', 'Biology and Chemistry', 'Language Studies') NOT NULL,
FOREIGN KEY (institution_id) REFERENCES institutions(institution_id)
```
### Таблиця Children: Створіть таблицю Children

При створеннi таблицi **Children**, я використав такi новi типи даних.
- **DATE** - для поля дати народження
- **YEAR** - для року вступу 
- **DECIMAL(10,2)** - для значення цiни навчання

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
### Таблиця Parents: Створіть таблицю Parents

При створеннi таблицi **Parents**, я використав такi типи даних.

```
parent_id INT AUTO_INCREMENT PRIMARY KEY,
first_name VARCHAR(50) NOT NULL,
last_name VARCHAR(50) NOT NULL,
child_id INT,
FOREIGN KEY (child_id) REFERENCES children(child_id) 
```

Пiсля створення таблиць в мене вийшла база данних з наступною структурою:

![image](https://github.com/user-attachments/assets/a09d3fd4-86f3-45c1-a7e7-3a9542a7ea58)

### Операції з даними: Вставте принаймні 3 записи

Зроблено) 
Це можна побачити у файлi `SchoolDB.sql`.

Готовий скрипт я запустив за допомогою наступної команди i перевiрив:

	mysql < SchoolBD.sql
	mysql
	show schemas;

Вона розгорнулася без проблем
## Запити:

Для першого завдання я використав цей запит.

	select child_id,first_name,last_name,institution_name,institutions_direction
	from children 
	join institutions ON children.institution_id = institutions.institution_id
	join classes ON children.class_id = classes.class_id;

![Pasted image 20241015040935](https://github.com/user-attachments/assets/cc65ecc7-09ea-4f70-bd5d-400ac4fc1e65)

Для запиту `Отримайте інформацію про батьків і їхніх дітей разом із вартістю навчання`, я використав наступний sql-запит.

	select children.child_id,children.first_name,children.last_name,
	age,parents.first_name AS parent_first_name,
	parents.last_name AS parent_last_name,tuition_fee 
	from children
	join parents ON children.child_id = parents.child_id;

Пiд час написанная цього запиту зiштовхнувся з проблемою те що iмена дiтей i батькiв мають однаковi iдентифiкатори i треба було використати алiас `AS`, щоб створити псевдонiм для стовбця `parents.first_name` i `parents.last_name`.
![Pasted image 20241015213237](https://github.com/user-attachments/assets/c457e164-5510-4f94-81eb-e41a23046069)

Для запиту `Отримайте список всіх закладів з адресами та кількістю дітей, які навчаються в кожному закладі` я використав наступний sql-запит.

	select institution_name, institutions.address, COUNT(children.child_id) AS children_count
	FROM institutions 
	JOIN children ON institutions.institution_id = children.institution_id
	GROUP BY institutions.institution_name, institutions.address\G;

A тут для того щоб порахувати кiлькiсть учнiв я використав функцiю `COUNT()`. А для групування sql оператор `GROUP BY`

![Pasted image 20241015214414](https://github.com/user-attachments/assets/3692238b-ed40-4621-8dba-addacc98e937)

## Зробіть бекап бази та застосуйте його для нової бази даних і перевірте

За допомогою команди `mysqldump schooldb > schooldb_backup.sql` я створив бекап.
Потiм видалив iснуючу БД `drop database schoolbd;`.

Створив знову базу данних i вiдтворив її з бекапу.

	CREATE DATABASE schooldb_backup;
	mysql schooldb_backup < /home/illia/schooldb_backup.sql

Для перевiрки використав один з запитiв якi писав вищє. Вiн спрацював i вивiв той самий результат.

# **Додаткове завдання: Анонімізація даних**
### Анонімізація таблиці Children:
Для анонiмiзацiї полiв `first_name, last_name, tuition_fee`, в таблицi `children` я використав наступний sql-запит:

	UPDATE children 
	SET first_name = 'Child',
	last_name = 'Annonymous',
	tuition_fee = ROUND(RAND() * (6000 - 3000) +3000,2);

У результатi вийшла занонiмiзована таблиця `children`.

![Pasted image 20241015220730](https://github.com/user-attachments/assets/24d7cf46-b771-4ee8-908d-b3d377f46253)


### Анонімізація таблиці Parents:
Для анонiмiзацiї полiв `first_name, last_name`, в таблицi `parents` я використав наступний sql-запит:

	SET @counter = 0;
	UPDATE parents
	SET first_name = CONCAT('Parent', @counter := @counter + 1),
	last_name = 'Anonymous';

У результатi вийшла занонiмiзована таблиця `parents`.

![Pasted image 20241015221912](https://github.com/user-attachments/assets/ad4cc3d4-2e03-4c37-9fa0-82524243f83d)
### Анонімізація таблиці Institutions:
Для анонiмiзацiї полiв `institution_name, address`, в таблицi `institutions` я використав наступний sql-запит:

	SET @counter = 0;
	UPDATE institutions
	SET institution_name = CONCAT('Institution', @counter := @counter + 1),
	address = CONCAT('Address', @counter);

У результатi вийшла занонiмiзована таблиця `institutions`.

![Pasted image 20241015222514](https://github.com/user-attachments/assets/7a8f6784-9aff-4dcb-96e6-74cc13b7623e)
