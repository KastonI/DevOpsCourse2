## 2. Створення нової віртуальної машини:
На цьому этапi я вибрав назву вiртуальної машини, мiсце розташування i iso образ який я використовував.

![Pasted image 20240903224430](https://github.com/user-attachments/assets/500c0c80-8c4e-4553-8b8a-6d67c53796e3)
## 3. Налаштування VM:

Тут вибрав кiлькiсть оперативної пам'яті та кількість ядер процесора.

![Hardware](https://github.com/user-attachments/assets/673038bc-51da-4a89-bd4c-0c9e54c01cba)

Для цієї віртуальної машини нам вистачить 20 Гб пам'яті, а також поставив галочку щоб віртуальний диск був статичний. (Це була помилка)

![VirtualHardDisk](https://github.com/user-attachments/assets/ba4c7e2e-5bbc-4dda-a25e-7ec8a51c3039)

А також мережевий адаптер типу `bridge`.

![Bridge](https://github.com/user-attachments/assets/25f10ebc-a59d-431f-8158-047079661203)

## 4. Інсталяція операційної системи:
Тут iso образ доданий як оптичний диск.

![Iso](https://github.com/user-attachments/assets/82604b71-aded-4caa-ab7b-bb1e701031e1)

### Виконайте інсталяцію Ubuntu на вашу віртуальну машину.
Під час встановлення було кілька базових питань, таких як вибір мови, імені користувача, пароля та інше.

![UbuntuInstall](https://github.com/user-attachments/assets/3823ac0f-21ff-4036-b016-d663b6da8085)

## 5. Збереження та відновлення стану VM:
### Створіть знімок (snapshot) вашої VM після налаштування системи
Відразу після встановлення я створив зріз системи, щоб зберегти її робочий стан.

![Snapshot](https://github.com/user-attachments/assets/9319d989-e6fc-40cb-9fbf-f950c672b5e5)

### Запустіть кілька базових команд (наприклад, створення файлу, rm -rf / ;)
Я запустив команду `rm -rf /` яка повністю вбила мою систему, після її виконання система не запускалася і єдине, що мені допомогло відновити її це зріз.

![RMrf]![Pasted image 20240903230743](https://github.com/user-attachments/assets/b60bfa2b-5bfc-4795-8e95-e1d9ab66c118)

### Відновіть VM до попереднього знімку.
Зрiз спрацював i система була у тому ж станi що i до експериментiв.

![SnappshotFix](https://github.com/user-attachments/assets/f3bce851-4497-42e7-8354-23a667176fbb)

## 6. Зміна параметрів віртуальної машини через графічний інтерфейс
### Збільшення розміру жорсткого диску:

На цьому етапi я зiштовхнувся з проблемою, що при створеннi диску фiксованного розмiру його розмiр в майбутньому не можна змiнити. Це не залежить вiд розширення файлу `.vdi` чи `.vhd`. На сторiнцi форуму VirtualBox пропонують створити копiю i змiнити тип вiртуального диску на динамiчний.

Я зробив це за допомогою команд `clonemedium` i `modifymedium`. 

![VDIfix](https://github.com/user-attachments/assets/05742bc1-b983-43ef-a088-378b23fa954c)

### Після збільшення розміру диску розширте файлову систему всередині Ubuntu
За допомогою команд якi менi дав ChatGPT я змiг розширити файлову систему))

![Resize](https://github.com/user-attachments/assets/60b3ad57-22fa-4cf3-a3c1-b5fecf2064b3)


Результат:

![ResultResize](https://github.com/user-attachments/assets/803e2f0b-f905-49d7-a720-6043f3312cd0)

### Зміна кількості процесорних ядер та оперативної пам'яті:

![ChangeHardware](https://github.com/user-attachments/assets/531b8a93-30ab-49f2-983e-f56415b0d44b)

### Вимкнення та видалення VM:
Для вимкнення я використав команду:

	shutdown -P now

А для видалення використав графiчний iнтерфейс i опцiю "вилучити з усiма файлами".

## Спiльна тека на Ubuntu Srever.
Для того щоб створити цю папку спочатку треба перейти в меню пристрої i вибрати "Встановити гостьовi доповнення".

![Folder](https://github.com/user-attachments/assets/ad36dbc1-87d4-42f4-956c-38d7ffcbf197)

Це створить вiртуальний Cdrom який треба змонтувати у папку.

![MountCdrom](https://github.com/user-attachments/assets/e067020a-eaa9-40cd-b3fb-457dde035d7c)


Там ми можемо знайти файл з назвою `VBoxLinuxAdditions.run`. Нам його треба запустити але перед цим виконати цю команду: 

	sudo apt-get install build-essential

Вона потрiбна щоб iнсталювати необхiднi бiблiотеки, а потiм виконуємо команду запуску файлу.

	./VBoxLinuxAdditions.run

Вiн встановить необхiднi доповнення. Далi створюємо папку для наших файлiв i вимикаємо вiртуальну машину.

	mkdir ubuntu_files

Пiсля цього заходимо в налаштування вiртуальної машини i налаштовуємо спiльну папку там.

![FolderInVM](https://github.com/user-attachments/assets/46008907-0cec-4f68-8cb9-745e8d517eb4)

В шлях до теки вибираємо мiсце на локальному компьютерi, а в `Mount point` прописуємо шлях до теки яку ми нещодавно створили на ВМ.
На цьому все, тепер файли з вашої локальної машини можна побачити на вiртуальнiй машинi.

![Finish](https://github.com/user-attachments/assets/ff4befc7-4f69-4380-8604-55be072ad59c)

