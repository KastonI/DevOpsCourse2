# Homework 02lesson(Git)

### Створіть репозиторій, налаштуйте доступ за допомогою ssh.
![Pasted image 20240831144933](https://github.com/user-attachments/assets/2ad77a13-03b6-459b-92c5-98fff0803c28)
### Закиньте у “main/master” скрипти з попередніх завдань.
![Pasted image 20240901214800](https://github.com/user-attachments/assets/946c1436-7c15-4ff8-bc1b-f5b7536f5c99)
### Створіть дві фіч-гілки: `feature-1` та `feature-2` з мастеру.
![Pasted image 20240901210559](https://github.com/user-attachments/assets/33ef9750-659e-47d7-a339-0a1a166651b1)
### Розробіть окрему функціональність для кожної фічі на відповідних гілках.
Скрипт для переносу файлiв з одного мiсця в iнше
branch feature-1 :
```python
import shutil
import os
def move_files(src, dst):
    for filename in os.listdir(src):
        shutil.move(os.path.join(src, filename), dst)
source_folder = 'Top secret'
destination_folder = 'My-server'
move_files(source_folder, destination_folder)
```

branch feature-2 з конфлiктом:
```python
import shutil
import os
def move_files(src, dst):
    for filename in os.listdir(src):
        shutil.move(os.path.join(src, filename), dst)
source_folder = 'Top secret'
destination_folder = 'Internet'
move_files(source_folder, destination_folder)
```

### Спробуйте злити `feature-2` з головною гілкою та розв'яжіть виниклі конфлікти
![Pasted image 20240901210559](https://github.com/user-attachments/assets/cb1c2f7a-0787-4450-be39-882e6e42f1e6)

### Внесіть нові зміни на гілці `feature-1` та спробуйте злити з головною гілкою шляхом **Pull Request**.
![Pasted image 20240901214253](https://github.com/user-attachments/assets/b8d451f8-2b72-4162-b169-04441d162409)

# Memes
![Gnome-deployer](https://github.com/user-attachments/assets/d856dcfb-5134-4827-a775-4778861bb657)