## Завдання 2: Створення файлу docker-compose.yml

У моєму **docker compose** файлi вийшло 4 сервiси. PostgreSQL база даних, Redis як кеш сервер, Web контейнер з Python i Flask, Nginx як reverse proxy i load balancer.

### З цiкавого у **docker compose** файлi можна видiлити:

Передача логiнiв i паролiв вiд БД i Redis через `.env` файл

	environment:
		POSTGRES_USER: ${POSTGRES_USER}
		POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
		POSTGRES_DB: ${POSTGRES_DB}

Використання `expose` для того щоб контейнери могли за допомогою портiв спiлкуватисся мiж собою, але при цьому вони не були вiдкритi назовнi.

	expose:
		- "5432:5432"

 `Volumes` для зберiгання БД, а також `init.sql` з флагом `ro` для створення таблиць i заповнення даними.

	 volumes:
		 - db-data:/var/lib/postgresql/data
		 - ./init/init.sql:/docker-entrypoint-initdb.d/init.sql:ro

`Healthcheck` за допомогою якого Flask перевiряє чи вже запустилася БД, а тiльки пicля неї запускається сам

	healthcheck:
		test: ["CMD", "pg_isready", "-U", "${POSTGRES_USER}","-d", "${POSTGRES_DB}"]
		start_period: 15s
		interval: 10s
		timeout: 5s
		retries: 3

Запуск Redis серверу з паролем з файлу `.env`

	    command: ["redis-server", "--requirepass", "${REDIS_PASSWORD}"]

`Volumes` для Nginx з файлом конфiгурацiї i звичайний volume

	volumes:
		- ./init/default.conf:/etc/nginx/conf.d/default.conf:ro
		- ./init/index.html:/usr/share/nginx/html/index.html

Бiлд `web` контейнеру на основi `python:3.11-alpine` з використання Multi Staging

	build: ./web/

Залежностi про якi писав вище для `web`

	depends_on:
		db:
			condition: service_healthy
		redis:
			condition: service_started

Знову `expose` для Flask, щоб помилково не пiдключатися до нього, а тiльки через проксi

	expose:
		- "5000:5000"

### Створіть файл index.html з простим змістом і додайте до web-data приклад коду:
Цей файл я трохи модифiкував i додав кнопку яка перенаправляє нас на `Localhost:80/data` де виводиться `sql-запит` у таблицю з додатковою iнформацiєю.

## Завдання 3: Запуск багатоконтейнерного застосунку
### Перевірте стан запущених сервісів:

Командою `docker compose ps`, я перевiрив застосунки, вони працюють

![Pasted image 20241101184627](https://github.com/user-attachments/assets/e469a2a1-2c52-4ea9-960b-54bb376b6c84)

### Перевірте роботу вебсервера:

Пiсля запуску контейнерiв, за посиланням `localhost:80` вiдкривається наступна сторiнка

![Pasted image 20241101184103](https://github.com/user-attachments/assets/8cd80b97-3626-470d-9b7c-da7069cc43b3)

Пiсля натискання на кнопку ми можемо побачити вивiд з БД. Нижче вказаний номер контейнеру який вивiв нам це, а також мiсце з якого було стягнутто цi даннi. При першому запуску це `bd`, але наш запит вже записаний у Redis, тому якщо оновити сторiнку джерело iнформацiї змiниться

![Pasted image 20241101184151](https://github.com/user-attachments/assets/31787e80-8dc1-4d0f-b772-f02d95facf8d)

Ось тут вже можно побачити що даннi було взято з Redis

![Pasted image 20241101184356](https://github.com/user-attachments/assets/0fc8b145-020a-4069-b5b7-27d5bd2ed583)

## Завдання 4: Налаштування мережі й томів
### Досліджуйте створені мережі та томи:

Пiсля використання команди `docker volume ls` я побачив два волюми, якi створив docker. Один для бази даних в якiй є даннi, а також волюм який створив для себе Redis.

А команда `docker network ls` вивела крiм стандартних ще кастомну мережу з назвою `multi-container-app_appnet`

### Перевірте підключення до бази даних:

Я використав команду `docker exec -ti postgres-db sh` i пiдключився до контейнеру з БД. 
За допомогою наступних команд я перевiрив чи є даннi якi мали iмпортуватись з `init.sql`.

	psql -U root -d devops
	SELECT * FROM test;

![Pasted image 20241102125507](https://github.com/user-attachments/assets/91500f6b-ff66-44eb-bfd7-3eb3e0c6d68e)

## Завдання 5: Масштабування сервісів

Для того щоб масштабувати сервiси i це мало хочаб якийсь сенс, я додав у вивiд сторiнки повiдомлення яка з машин оброблювала це повiдомлення.

	response:{ 'host_number': f'Hello from Flask running in {os.environ.get("HOSTNAME")}!'}

Також я трiшки змiнив конфiгурацiю nginx щоб вiн працював як проксi. А саме перенаправляв трафiк з `localhost:80/data`, на `http://web:5000/data`. Також так як це запущено у Docker то вiн автоматично балансує трафiк мiж контейнерами. 

Пiсля запуску 3 контейнерiв `web` я отримав такий результат:

	docker-compose up -d --scale web=3`

![Pasted image 20241101185341](https://github.com/user-attachments/assets/2ee3ff3e-f5d9-45d4-95b0-c5f22c2c265f)

Пiсля того як запустились цi контейнери, я зайшов на localhost i декiлька разiв перезавантажив сторiнку. Кожен раз по кругу вiдповiдали 3 рiзнi контейнери по колу.

![Pasted image 20241101185449](https://github.com/user-attachments/assets/3a0266f6-4f5d-469c-afcf-04c86ca73cfe)
![Pasted image 20241101185427](https://github.com/user-attachments/assets/4d4d9526-1d04-4e40-b934-001e31a81170)
![Pasted image 20241101185425](https://github.com/user-attachments/assets/61076613-6403-40c9-bdff-a183312d94c5)



