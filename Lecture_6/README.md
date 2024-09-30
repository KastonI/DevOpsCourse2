# Домашнє завдання з теми "Advanced Linux"

## Встановити й налаштувати вебсервер Nginx через офіційний репозиторій. 

Для того щоб виконати цi дiї спочатку оновлюємо пакети i встановлюємо `Nginx`.

	apt update && apt upgrade
	apt install nginx -y

Також можна перевiрити чи коректно встновився `nginx` цiєю командою.

	systemctl status nginx

## Додати й видалити PPA-репозиторій для Nginx, а потім повернутися до офіційної версії пакета за допомогою ppa-purge.

Для цього я використав команди з офiцiйної сторiнки `nginx`.
Завантажуємо необхiдних пакети для iнсталювання:

	apt install curl gnupg2 ca-certificates lsb-release debian-archive-keyring

Додаємо офiцiйний ключ для iнсталювання вебсерверу:

	curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
    | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null

Команда для перевiрки iмпортованого ключа:

	gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg

Вибираємо які використовувати пакети для основної версії nginx, замість попередньої:

	echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] 
	http://nginx.org/packages/mainline/debian `lsb_release -cs` nginx" \
    | sudo tee /etc/apt/sources.list.d/nginx.list

Команда для використання пакетів з репозиторію `nginx` замість стандартних:

	echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" \
    | sudo tee /etc/apt/preferences.d/99nginx

Для видалення я зайшов у файл `nginx.list` i видалив шлях до вiддаленого репозиторiю:

	nano /etc/apt/sources.list.d/nginx.list

Оновлення списку пакетiв:

	apt update

Далi видаляємо звичайну версiю i встановлюємо `stable`:

	apt remove nginx nginx-common
	apt install nginx

Перевiрка iнстальованої версiї:

	nginx -V
## Написати й налаштувати власний systemd-сервіс для запуску простого скрипта (наприклад, скрипт, який пише поточну дату і час у файл щохвилини).

За допомогою `nano` я створив файл `date_and_time` i зробив у ньому наступний скрипт

	#!/bin/bash
	echo "Поточна дата i час: $(date +"%Y-%m-%d %H:%M:%S")" >> /var/log/date_and_time.log

Також додав права на виконання скрипту

	chmod +x date_and_time.sh

Для того щоб перевiрити в ручну запустив скрипт i прочитав log файл

	./opt/date_and_time
	cat /var/log/date_and_time.log
### Створення сервiсу

Створюємо файл сервiсу `nano /etc/systemd/system/date_and_time.service` з наступними параметрами:

	[Unit]
	Description=Date and time service
	
	[Service]
	ExecStart=/opt/date_and_time.sh
	
	[Install]
	WantedBy=multi-user.target

Далi треба перезавантажити конфiгурацiю i запустити конфiгурацiю щоб перевiрити чи працює процес: 

	systemctl daemon-reload
	systemctl start data_and_time.service
	cat /var/log/date_and_time.log

Тепер командою `nano /etc/systemd/system/date_and_time.timer` створюємо файл таймеру який буде що хвилини перезавантажувати наш сервic:

	[Unit]
	Description=timer for date
	
	[Timer]
	OnBootSec=0sec
	OnUnitActiveSec=1min
	AccuracySec=1s
	Unit=date_and_time.service
	
	[Install]
	WantedBy=timers.target

Знову перезавантажуємо конфiгурацiю i запускаємо таймер.

	systemctl daemon-reload
	systemctl start data_and_time.timer
	systemctl enable data_and_time.timer
	tail -f /var/log/date_and_time.log
Все тепер кожну хвилину таймер додає теперiшню дату i час до файлу `/var/log/date_and_time.log`.
![date_and_time](https://github.com/KastonI/privat/blob/master/Pasted%20image%2020240916235827.png)

## Налаштувати брандмауер за допомогою UFW або iptables. Заборонити доступ до порту 22 (SSH) з певного IP, але дозволити з іншого IP.
Iнсталюємо `ufw`:

	apt install ufw

За замовчуванням `ufw` вимкнений, а усі вихідні запити дозволені, а всі вхідні – заборонені. Тому перед увімкненням мені потрібно дозволити доступ по SSH (port 22) з моєї ip адреси i заборонити з iношої.

	ufw allow from 192.168.1.88 to any port 22
	ufw deny from 192.168.1.11 to any port 22

Тепер можна ввiмкнути `ufw`, а також перевiрити його стан:

	ufw enable
	ufw status

## Налаштувати Fail2Ban для захисту від підбору паролів через SSH.
Спочатку треба iнсталювати `fail2ban` на наш сервер:

	apt install fail2ban

Тепер скопiюємо i змiнимо файл конфiгурацiї:

	cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
	nano /etc/fail2ban/jail.local

В цьому файлi я змiнив наступнi параметри:

	bantime = 1h
	findtime = 10m
	maxretry = 5

А в блоцi `[sshd]` цi:

	enabled = true
	port = 22
	logpath = /var/log/auth.log

Далi треба створити лог файл за шляхом `/var/log/auth.log` i перезавантажити службу 

	touch /var/log/auth.log
	systemctl restart fail2ban.service

Для перевiрки статусу можна використати команду 

	fail2ban-client status

## Створити й змонтувати новий розділ на диску, налаштувати його для автоматичного монтування під час завантаження системи.
Для цього я вставив у сервер флешку без файлової системи.

![/dev/sdb](https://github.com/KastonI/privat/blob/master/Pasted%20image%2020240917110339.png)

Далi створюємо новий роздiл за допомогою `fdisk`

	sudo fdisk /dev/sdb 

Потiм робимо розмiтку файлової системи за допомогою команди:

	mkfs.ext4 /dev/sdb1

Пiсля створення файлової системи створюємо директорiю i монтуємо в неї цей диск. Для себе я обрав цей шлях `/home/illia/files`

	mkdik /home/illia/files
	mount /dev/sdb1 /home/illia/files	

![Before reboot](https://github.com/KastonI/privat/blob/master/Pasted%20image%2020240917111629.png)

Для того щоб цей диск автоматично прикрiплявся до цiєї папки треба прописати це при запуску системи:

	nano /etc/fstab

I в цьому файлi вписуємо наступний рядок:

	UUID=2e58d914-e095-47a0-bd87-06f3f667120c /home/illia/files ext4 defaults 0 1

Пiсля перезавантаження наш зроблений `maunt` залишився i працює

![After reboot](https://github.com/KastonI/privat/blob/master/Pasted%20image%2020240917112558.png)




