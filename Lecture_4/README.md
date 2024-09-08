## VM1 (загальнодоступний вебсервер):
- Host-name : `Public-server`
- Box-файл :`bento/ubuntu-24.04`
- Спiльная папка : `./sync_folder`
- Проброс портiв бо буду встановлювати Nginx : `guest: 80, host: 8080`

Команди якi використовуються через provision :
- `apt-get update` i `apt-get upgrade` для оновлення пакетiв
- `apt-get install -y nginx` - iнсталяцiя Nginx.
- `sudo cp /vagrant_sync_folder/index.html /var/www/html` - копiювання html сторiнки з спiльної папки до Nginx.
- `sudo systemctl restart nginx` - рестарт Nginx щоб можна було побачити сторiнку.

Також в процессi вирiшення додаткового задвання i перегляду сайту Vagrant. Зрозумiв що лiпше буде не копiювати файл, а створити `symlink` через поширену папку. Це надасть зручностi у використаннi i оновленнi сторiнки. Але все ж таки вирiшив залишити це як є i тiльки зазначити що це один з варiантiв.

## VM2 (приватний сервер):
- Host-name : `private-server`
- Box-файл :`bento/ubuntu-24.04`
- Спiльная папка : `./sync_folder`
- Статичний Ip: `192.168.100.38`

Команди якi використовуються через provision :
- `apt-get update` i `apt-get upgrade` для оновлення пакетiв
- `echo "Оновлення завершено!"` звичайний echo

## VM3 (загальнодоступний сервер зі статичним IP):
- Host-name : `private-server`
- Box-файл :`bento/ubuntu-24.04`
- Спiльная папка : `./server`
- Статичний Ip: `192.168.100.39`
- Bridge: `MediaTek Wi-Fi 6/6E Wireless USB LAN Card`

## Додаткове завдання
Я додав двi глобальнi змiннi:
- `num_of_machines = 3` - де задається кiлькiсть створених машин
- `first_ip = 11` - початкова Ip адреса для вiртуальних машин

Для створення машин я використав iтератор **each** `(1..num_of_machines).each do |num|`. 
(пiдгледiв саме на сайтi Vagrant). 

У кодi нижче створюється окрема папка всерединi папки `sync_folder` для кожної з машин.

	folder_machine = "./sync_folder/Virtual-machine#{num}"
	FileUtils::mkdir_p folder_machine

Далi при налаштуваннi саме вiртуальних машин у мiсцях де повиннi вiдрязнятись назви/числа(Define, ip, host-name, provision). Я додав конструкцiю `#{num}` для того щоб цифра з циклу додавалася до назви або числа.

У змiннiй `folder_machine` зберiгається шлях до створеної спецiально для цiєї машини папки.
`vm.vm.synced_folder folder_machine, "/vagrant_sync_folder"`.

В кiнцi коли вiртуально машина створена вона через provision виконується команда `echo hello from VM#{num}`.