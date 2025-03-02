CREATE DATABASE IF NOT EXISTS schooldb;

USE schooldb;

CREATE TABLE IF NOT EXISTS institutions (
    institution_id INT AUTO_INCREMENT PRIMARY KEY,
    institution_name VARCHAR(100) NOT NULL,
    institution_type ENUM('School', 'Kindergarten') NOT NULL,
    address VARCHAR(150) NOT NULL
);
CREATE TABLE IF NOT EXISTS classes (
    class_id INT AUTO_INCREMENT PRIMARY KEY,
    class_name VARCHAR(50) NOT NULL,
    institution_id INT,
    institutions_direction ENUM('Mathematics', 'Biology and Chemistry', 'Language Studies') NOT NULL
);

CREATE TABLE IF NOT EXISTS children (
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
);
CREATE TABLE IF NOT EXISTS parents (
    parent_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    child_id INT,
    FOREIGN KEY (child_id) REFERENCES children(child_id)
);

CREATE USER IF NOT EXISTS 'illia'@'192.168.%.%' IDENTIFIED BY 'pas123';

GRANT SELECT, INSERT, UPDATE, DELETE, CREATE TEMPORARY TABLES ON schooldb.* TO 'illia'@'192.168.%.%';

FLUSH PRIVILEGES;

INSERT INTO institutions (institution_name, institution_type, address)
VALUES
('Лiцей №42', 'School', 'вул. Дунайська, 51, м.Камянське, Дніпропетровська область'),
('Дитячий садок "Пролісок"', 'Kindergarten', 'Гулянка, Житомирська область'),
('Хмельницький технологічний багатопрофільний ліцей', 'School', 'вулиця Тернопільська, 14/1, Хмельницький, Хмельницька область');

INSERT INTO classes (class_name, institution_id, institutions_direction)
VALUES
('9-Б', '3', 'Biology and Chemistry'),
('Середня група', '2', 'Language Studies'),
('7-A', '1', 'Mathematics'),
('5-В', '1', 'Language Studies');

INSERT INTO children (first_name, last_name, birth_date, year_of_entry, age, institution_id, class_id, tuition_fee)
VALUES
('Олег', 'Іванов', '2009-05-15', 2023, 14, 3, 1, 5000.00),
('Анна', 'Петренко', '2018-08-20', 2023, 5, 2, 2, 3300.00), 
('Дмитро', 'Коваль', '2010-09-10', 2023, 13, 1, 3, 4800.00),
('Катерина', 'Сидоренко', '2011-04-01', 2023, 12, 3, 3, 5300.00);

INSERT INTO parents (first_name, last_name, child_id)
VALUES
('Світлана', 'Іванова', 1),
('Марина', 'Петренко', 2),
('Олександр', 'Коваль', 3),
('Тетяна', 'Сидоренко', 4);