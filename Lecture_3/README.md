## 2. Створення нової віртуальної машини:
На цьому этапi я вибрав назву вiртуальної машини, мiсце розташування i iso образ який я використовував.

![UbuntuSrv](https://github.com/KastonI/privat/blob/master/Pasted%20image%2020240903224430.png)
## 3. Налаштування VM:

Тут вибрав кiлькiсть оперативної пам'яті та кількість ядер процесора.

![Hardware](https://github.com/KastonI/privat/blob/master/Pasted%20image%2020240903224511.png)

Для цієї віртуальної машини нам вистачить 20 Гб пам'яті, а також поставив галочку щоб віртуальний диск був статичний. (Це була помилка)

![VirtualHardDisk](https://github.com/KastonI/privat/blob/master/Pasted%20image%2020240903224532.png)

А також мережевий адаптер типу `bridge`.

![Bridge](https://github.com/KastonI/privat/blob/master/Pasted%20image%2020240903224748.png)

## 4. Інсталяція операційної системи:
Тут iso образ доданий як оптичний диск.

![Iso](https://github.com/KastonI/privat/blob/master/Pasted%20image%2020240903225203.png)

### Виконайте інсталяцію Ubuntu на вашу віртуальну машину.
Під час встановлення було кілька базових питань, таких як вибір мови, імені користувача, пароля та інше.

![UbuntuInstall](https://github.com/KastonI/privat/blob/master/Pasted%20image%2020240903230200.png)

## 5. Збереження та відновлення стану VM:
### Створіть знімок (snapshot) вашої VM після налаштування системи
Відразу після встановлення я створив зріз системи, щоб зберегти її робочий стан.

![Snapshot](https://github.com/KastonI/privat/blob/master/Pasted%20image%2020240903230924.png)

### Запустіть кілька базових команд (наприклад, створення файлу, rm -rf / ;)
Я запустив команду `rm -rf /` яка повністю вбила мою систему, після її виконання система не запускалася і єдине, що мені допомогло відновити її це зріз.

![RMrf](https://github.com/KastonI/privat/blob/master/Pasted%20image%2020240903230743.png)

### Відновіть VM до попереднього знімку.
Зрiз спрацював i система була у тому ж станi що i до експериментiв.

![SnappshotFix](https://github.com/KastonI/privat/blob/master/Pasted%20image%2020240903231158.png)

## 6. Зміна параметрів віртуальної машини через графічний інтерфейс
### Збільшення розміру жорсткого диску:

На цьому етапi я зiштовхнувся з проблемою, що при створеннi диску фiксованного розмiру його розмiр в майбутньому не можна змiнити. Це не залежить вiд розширення файлу `.vdi` чи `.vhd`. На сторiнцi форуму VirtualBox пропонують створити копiю i змiнити тип вiртуального диску на динамiчний.

Я зробив це за допомогою команд `clonemedium` i `modifymedium`. 

![VDIfix](https://github.com/KastonI/privat/blob/master/Pasted%20image%2020240904001818.png)

### Після збільшення розміру диску розширте файлову систему всередині Ubuntu
За допомогою команд якi менi дав ChatGPT я змiг розширити файлову систему))

![Resize](https://github.com/KastonI/privat/blob/master/Pasted%20image%2020240904012951.png)

Результат:

![ResultResize](https://github.com/KastonI/privat/blob/master/Pasted%20image%2020240904013011.png)

### Зміна кількості процесорних ядер та оперативної пам'яті:

![ChangeHardware](https://github.com/KastonI/privat/blob/master/Pasted%20image%2020240904013425.png)

### Вимкнення та видалення VM:
Для вимкнення я використав команду:

	shutdown -P now

А для видалення використав графiчний iнтерфейс i опцiю "вилучити з усiма файлами".

## Спiльна тека на Ubuntu Srever.
Для того щоб створити цю папку спочатку треба перейти в меню пристрої i вибрати "Встановити гостьовi доповнення".

![Folder](https://github.com/KastonI/privat/blob/master/Pasted%20image%2020240904024401.png)

Це створить вiртуальний Cdrom який треба змонтувати у папку.

![MountCdrom](https://github.com/KastonI/privat/blob/master/Pasted%20image%2020240904024551.png)

Там ми можемо знайти файл з назвою `VBoxLinuxAdditions.run`. Нам його треба запустити але перед цим виконати цю команду: 

	sudo apt-get install build-essential

Вона потрiбна щоб iнсталювати необхiднi бiблiотеки, а потiм виконуємо команду запуску файлу.

	./VBoxLinuxAdditions.run

Вiн встановить необхiднi доповнення. Далi створюємо папку для наших файлiв i вимикаємо вiртуальну машину.

	mkdir ubuntu_files

Пiсля цього заходимо в налаштування вiртуальної машини i налаштовуємо спiльну папку там.

![FolderInVM](https://github.com/KastonI/privat/blob/master/Pasted%20image%2020240904025502.png)

В шлях до теки вибираємо мiсце на локальному компьютерi, а в `Mount point` прописуємо шлях до теки яку ми нещодавно створили на ВМ.
На цьому все, тепер файли з вашої локальної машини можна побачити на вiртуальнiй машинi.

![Finish](https://github.com/KastonI/privat/blob/master/Pasted%20image%2020240904025949.png)
