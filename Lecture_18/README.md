# Docker Swarm
## Завдання 1: Ініціалізація Docker Swarm кластера
### Ініціалізацiя Swarm кластеру
Для цього я використав цю команду

	docker swarm init
### Додаткова нода
Потiм командою з виводу мастеру додав воркер у кластер

	docker swarm join --token SWMTKN-1-6863n9ffffv2c5ysz51sogjdb7rch314h7c45bgiip3n4htn84-1rznttqu9z5kd6a1h37idpqlm 10.10.10.13:2377
### Перевiрка стану кластера

	docker node ls

![Pasted image 20241106181601](https://github.com/user-attachments/assets/c116653d-7b2b-437f-a0e3-9b4ebd036b54)

## Завдання 2: Створення та управління сервісами
### Створіть простий вебсервіс nginx
Цiєю командою я запустив контейнер на майстер нодi. 

	docker service create --name web --publish published=8080,target=80 nginx

Потiм я хотiв перемiстити його на worker, тому додатково використав команду `update`

	docker service update web --constraint-add 'node.hostname == srv-2'

![Pasted image 20241106220721](https://github.com/user-attachments/assets/e00bbe24-876a-4cc9-a9ae-a9467ba065ae)

У подальшому це зламало балансування контейнерiв, тому я вирiшив змиритись i прибрав це обмеження, але знайшов iнформацiю що можна зробити прiорiтети через `labels`.
### Масштабуйте вебсервіс до 3 реплік
Для цього використав команду 

	docker service scale web=3

![Pasted image 20241106221334](https://github.com/user-attachments/assets/0c80896a-d3a1-438f-be7b-1a3f97f6fa75)


Сервiс працює i можна отримати доступ до його сторiнки.

![Pasted image 20241106221429](https://github.com/user-attachments/assets/df6b0519-7b88-44f6-880d-5d297081ffc7)

### Завдання 3-4: Створення стека i використання секретів

Для того щоб пiдняти стек з минулого домашнього завдання менi спочатку знадобилось зробити бiлд застосунку який виводив даннi з бази даних. А потiм вигрузити його на Docker Hub, знайти його можна за таким ім'ям `kastonl/web-flask:latest`.

Так як змiннi передавалися туди через `.env` файл, у бiлдi немає чутливих данних тiльки посилання на змiннi, якi треба вказати.

З минулого файлу `docker-compose.yaml` я змiнив декiлька речей. А саме додав до кожного контейнеру 

	deploy:
		restart_policy:
			condition: on-failure

А до `web` контейнеру додав кiлькiсть реплiк 3.

	replicas: 3

Також як виявилось `depends_on`, `container_name`, `expose` не працює в swarm, тому їх треба було прибрати.

Додав `secrets` до контейнерiв якi їх потребують

	secrets:
		- REDIS_PASSWORD
		- POSTGRES_USER
		- POSTGRES_PASSWORD
	environment:
		- REDIS_PASSWORD: /run/secrets/REDIS_PASSWORD
		- POSTGRES_USER: /run/secrets/POSTGRES_USER
		- POSTGRES_PASSWORD: /run/secrets/POSTGRES_PASSWORD

I додав їх у середовищє `Docker Swarm`:

Крiм цього щє використав компонент `configs`, щоб конфiги для nginx i db були доступнi з будь якої ноди, а не тiльки з майстру.

У випадку з `index.html` я вирiшив його теж поширити через `configs`, але якщо його треба перiодично змiнювати краще використати зовнiшнiй nfs сервер.

	configs:
		nginx_config:
			external: true
		db_init:
			external: true
		index_html:
			external: true

Пiсля запуску стеку через вiдсутнiсть `depends_on` деякi сервiси падають, тому що вони не можуть пiдє'днатись до бази даних. Але для docker swarm це нормально, вони ж все одно перезапустяться))

Для використання секретiв i конфiгiв я додав їх у середовище **Docker Swarm**.

	echo "8mf2j4a8mr3" | docker secret create POSTGRES_PASSWORD -
	echo "root" | docker secret create POSTGRES_USER -
	echo "dm239gm2d8s" | docker secret create REDIS_PASSWORD -

	docker config create db_init ./init/init.sql
	docker config create index_html ./init/index.html
	docker config create nginx_config ./init/default.conf

Пiсля всих цих налаштувань docker swarm пiднiмає всi 6 контейнерiв якi спiлкуються мiж собою i справно працюють.

![Pasted image 20241108170202](https://github.com/user-attachments/assets/e2ad780e-6ffd-431c-a5c6-950b5ed4c4e6)

![Pasted image 20241108170206](https://github.com/user-attachments/assets/793e20bf-e2f2-4c0b-9b9a-dd133bead1b0)
