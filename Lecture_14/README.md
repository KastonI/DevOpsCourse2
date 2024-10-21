# Домашнє завдання з теми "NoSQL"

## Створення бази даних та колекцій

Були використанi наступнi команди:

	use gymDatabase
	db.createCollection("clients")
	db.createCollection("memberships")
	db.createCollection("workouts")
	db.createCollection("trainers")

Результат:

![Pasted image 20241020200740](https://github.com/user-attachments/assets/75dddbd4-f62f-4298-8cf6-613c5b4449a7)

## Заповнення колекцій даними:

Для генерацiї даних за вiдповiдною схемою я використав iнструмент `mockaroo` i експортував даннi з нього в JSON. 

### Для колекцiї `clients` я використав такi налаштування i вiд себе додав поле `gender`.

![Pasted image 20241020210054](https://github.com/user-attachments/assets/fcab8a9a-2d23-43a8-b64f-7d2e114afa68)

### Для колекцiї `memberships` я використав такi налаштування.

(age там тiльки для присвоєння типу абонементу: студентський, сiмейний або звичайний)

![Pasted image 20241020214207](https://github.com/user-attachments/assets/58a11816-f25c-4073-885d-3aedbbc2346d)

### Для колекцiї `workouts` я використав такi налаштування.

В полi `descriptions` я виписав 6 типiв тренувань, а загальна кiлькiсть генерованих рядкiв теж 6.

![Pasted image 20241020220239](https://github.com/user-attachments/assets/85ea2dfe-d3cf-4ed5-8609-2713a0f7d59a)

### Для колекцiї `trainers` я використав такi налаштування.

У полi `specjalization` випадкова назва тренування кiлькiстью вiд 1 до 3.

![Pasted image 20241020222454](https://github.com/user-attachments/assets/9a717149-2a8c-4536-aa57-b0bca30bfcf4)

### Для iмпортування цих `.json` файлiв я використав наступнi команди

	mongoimport --db gymDatabase --collection clients --file /home/illia/clients.json --jsonArray
	mongoimport --db gymDatabase --collection memberships --file /home/illia/membership.json --jsonArray
	mongoimport --db gymDatabase --collection workouts --file /home/illia/Workouts.json --jsonArray
	mongoimport --db gymDatabase --collection trainers --file /home/illia/trainers.json --jsonArray

![Pasted image 20241020225150](https://github.com/user-attachments/assets/1b94fdf0-d5ec-4004-8545-3b726cba6841)

## Запити:

### Знайдіть всіх клієнтів віком понад 30 років

Для виконання цього запиту я використав наступну команду i вимкнув вивiд наступних полiв `_id`, `client_id`, `email`.

	db.clients.find({age: { $gt: 30}}, {client_id: 0, _id: 0, email: 0}).pretty()

![photo_2024-10-20_23-07-24](https://github.com/user-attachments/assets/9f32e1b3-03dc-4a4c-94b4-2bb6cab8401b)

### Перелічіть тренування із середньою складністю

Для виконання цього запиту я використав наступну команду i вимкнув вивiд поля `_id`.

	db.workouts.find({difficulty: "Medium"}, {_id: 0}).pretty()

![Pasted image 20241021004806](https://github.com/user-attachments/assets/9c490088-6608-427a-9bd4-142d4636268d)

### Покажіть інформацію про членство клієнта з певним client_id

Для виконання цього запиту я використав наступну команду. Вона використовує `aggregate` для пошуку i має 4 стейджi.
- `$match` - для вибору id пошуку
- `$lookup` - для поєднання таблицi membership i clients
- `$unwind` - розгортає масив на рiзнi документи
- `$project` - формує фiнальний документ

```
db.memberships.aggregate([
  {
    "$match": {
      "client_id": 7
    }
  },
  {
    "$lookup": {
      "from": "clients",
      "localField": "client_id",
      "foreignField": "client_id",
      "as": "client_info"
    }
  },
  {
    "$unwind": {
      "path": "$client_info"
    }
  },
  {
    "$project": {
      "_id": 0,
      "client_id": "$client_id",
      "client_name": "$client_info.name",
      "membership_start": "$start_date",
      "membership_end": "$end_date",
      "membership_type": "$type"
    }
  }
])
```

Вивiд:

![Pasted image 20241021023242](https://github.com/user-attachments/assets/d56acc88-7d1e-49ae-9777-1d36dd1fa787)
