# **Homework on the Topic "NoSQL"**

## **Creating a Database and Collections**
The following commands were used:

```
use gymDatabase
db.createCollection("clients")
db.createCollection("memberships")
db.createCollection("workouts")
db.createCollection("trainers")
```

### **Result:**
![Pasted image 20241020200740](https://github.com/user-attachments/assets/75dddbd4-f62f-4298-8cf6-613c5b4449a7)

---

## **Populating Collections with Data**
To generate data according to the required schema, I used the **Mockaroo** tool and exported the data as JSON.

### **For the `clients` collection, I used the following settings and added the `gender` field manually.**
![Pasted image 20241020210054](https://github.com/user-attachments/assets/fcab8a9a-2d23-43a8-b64f-7d2e114afa68)

---

### **For the `memberships` collection, I used the following settings.**
(Note: The `age` field is used only to determine the membership type: student, family, or regular.)

![Pasted image 20241020214207](https://github.com/user-attachments/assets/58a11816-f25c-4073-885d-3aedbbc2346d)

---

### **For the `workouts` collection, I used the following settings.**
- In the `descriptions` field, I listed **six types of workouts**.
- The total number of generated records is also **six**.

![Pasted image 20241020220239](https://github.com/user-attachments/assets/85ea2dfe-d3cf-4ed5-8609-2713a0f7d59a)

---

### **For the `trainers` collection, I used the following settings.**
- The `specialization` field contains a **randomly assigned workout type** (between 1 and 3 specializations).

![Pasted image 20241020222454](https://github.com/user-attachments/assets/9a717149-2a8c-4536-aa57-b0bca30bfcf4)

---

### **Importing JSON Files into MongoDB**
The following commands were used:

```
mongoimport --db gymDatabase --collection clients --file /home/illia/clients.json --jsonArray
mongoimport --db gymDatabase --collection memberships --file /home/illia/membership.json --jsonArray
mongoimport --db gymDatabase --collection workouts --file /home/illia/Workouts.json --jsonArray
mongoimport --db gymDatabase --collection trainers --file /home/illia/trainers.json --jsonArray
```

### **Import Result:**
![Pasted image 20241020225150](https://github.com/user-attachments/assets/1b94fdf0-d5ec-4004-8545-3b726cba6841)

---

## **Queries:**

### **Find all clients over the age of 30**
For this query, I used the following command and **excluded** the `_id`, `client_id`, and `email` fields from the output.

```
db.clients.find({age: { $gt: 30}}, {client_id: 0, _id: 0, email: 0}).pretty()
```

### **Query Result:**
![photo_2024-10-20_23-07-24](https://github.com/user-attachments/assets/9f32e1b3-03dc-4a4c-94b4-2bb6cab8401b)

---

### **List all workouts with a medium difficulty level**
For this query, I used the following command and **excluded** the `_id` field.

```
db.workouts.find({difficulty: "Medium"}, {_id: 0}).pretty()
```

### **Query Result:**
![Pasted image 20241021004806](https://github.com/user-attachments/assets/9c490088-6608-427a-9bd4-142d4636268d)

---

### **Show membership information for a client with a specific `client_id`**
For this query, I used the following **aggregation pipeline** with four stages:
1. **`$match`** – filters the query by `client_id`
2. **`$lookup`** – joins the `memberships` and `clients` collections
3. **`$unwind`** – expands the array into separate documents
4. **`$project`** – structures the final output

```json
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

### **Query Result:**
![Pasted image 20241021023242](https://github.com/user-attachments/assets/d56acc88-7d1e-49ae-9777-1d36dd1fa787)