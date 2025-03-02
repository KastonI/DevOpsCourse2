# Jenkins

## Деплой Jenkins

За допомогою **Terraform** я вирішив підняти два інстанси:  
- Один для самого Jenkins.  
- Другий для деплою на нього.

За допомогою **Ansible** я встановив Jenkins, а потім через UI додав необхідні плагіни. Крім цього, я підключився до інстансу за допомогою SSH та встановив потрібні пакети, такі як `openjdk-17-jdk` та `maven`.

Також через UI я додав:
- SSH-ключ для доступу до мого GitHub.
- Ще один ключ для доступу до EC2, на якому буде запускатись створений пакет.

**Додатково:**  
Для завдання з Telegram Notification я додав у credentials параметр `secret text` (один з `telegram_api`), а також `client_id` з ID мого чату.

---

## Налаштування EC2

Я підключився до інстансу та встановив необхідний пакет `openjdk-17-jdk` для роботи Spring Boot.

---

## Налаштування Freestyle Job

Спочатку я налаштував SSH-ключ для доступу до репозиторію. Після цього дозволив використовувати secrets у пайплайні та налаштував `ssh-agent` для доступу до EC2.

### Stages для збірки та деплою аплікації

#### Збірка (Build)

```bash
set +e

cd initial
mvn clean install
BUILD_STATUS=$?

if [ $BUILD_STATUS -eq 0 ]; then
    echo "✅ Білд завершився успішно."
else
    echo "❌ Білд завершився з помилкою."
fi
```

#### Деплой

```bash
REMOTE_USER=ubuntu
REMOTE_HOST=44.200.11.223
DST_FOLDER=/home/ubuntu/app

ssh -o StrictHostKeyChecking=no $REMOTE_USER@$REMOTE_HOST "mkdir -p $DST_FOLDER"
scp -o StrictHostKeyChecking=no -r initial/target/*.jar $REMOTE_USER@$REMOTE_HOST:$DST_FOLDER
ssh -o StrictHostKeyChecking=no $REMOTE_USER@$REMOTE_HOST "cd $DST_FOLDER && nohup java -jar *.jar > app.log 2>&1 & exit"
```

Після виконання пайплайну можна перевірити роботу аплікації за допомогою команди:

```bash
curl http://44.200.11.223:8080
```

Відповідь має бути такою:

```
Greetings from Spring Boot!
```

---

## Створення Jenkinsfile у репозиторії

Для цього завдання я використав наступний `deploy.Jenkinsfile` файл.

### Параметри

```groovy
pipeline {
    agent any

    parameters {
        string(name: 'REMOTE_USER', defaultValue: 'ubuntu', description: 'User for ssh')
        string(name: 'REMOTE_HOST', defaultValue: '44.200.11.223', description: 'Host for ssh')
        string(name: 'DST_FOLDER', defaultValue: '/home/ubuntu/app', description: 'App folder')
    }
}
```

### Білд аплікації

```groovy
stages {
    stage('Clone Repository') {
        steps {
            git branch: 'main', credentialsId: 'Github', url: 'git@github.com:KastonI/lecture-34-springboot.git'
        }
    }

    stage('Build') {
        steps {
            script {
                echo "Build project"
                sh 'cd initial && mvn clean install'
            }
        }
    }
}
```

### Деплой на EC2 інстанс

```groovy
stage('Prepare Remote Directory') {
    steps {
        sshagent(credentials: ['instance_test_key']) {
            sh "ssh -o StrictHostKeyChecking=no ${params.REMOTE_USER}@${params.REMOTE_HOST} \"mkdir -p ${params.DST_FOLDER}\""
        }
    }
}

stage('Transfer Files') {
    steps {
        sshagent(credentials: ['instance_test_key']) {
            sh "scp -o StrictHostKeyChecking=no -r initial/target/*.jar ${params.REMOTE_USER}@${params.REMOTE_HOST}:${params.DST_FOLDER}"
        }
    }
}

stage('Run on Remote Server') {
    steps {
        sshagent(credentials: ['instance_test_key']) {
            sh "ssh -o StrictHostKeyChecking=no ${params.REMOTE_USER}@${params.REMOTE_HOST} \"cd ${params.DST_FOLDER} && nohup java -jar *.jar > app.log 2>&1 & exit\""
        }
    }
}
```

Весь pipeline успішно виконав деплой аплікації.

![image](https://github.com/user-attachments/assets/f4d9a3a2-1ac9-4c2e-a8cd-9cd27c8eec25)

---

## Налаштування нотифікацій в Telegram

Спочатку я багато часу намагався реалізувати це через плагіни Jenkins, проте:
- Перший плагін був створений 7 років тому і бібліотека для його роботи вже не входить до ядра Jenkins.
- Інший плагін не надсилав повідомлень щоб я не робив i як не змiнював конфiгурацiї
- Був ще третiй який працював через зовнішній сервіс але з ним теж не вийшло.

Тому я вирішив зробити нотифікації за допомогою `curl` запитів у Freestyle Job.

### Stage: Build

```bash
set +e

cd initial
mvn clean install
BUILD_STATUS=$?

if [ $BUILD_STATUS -eq 0 ]; then
    BUILD_STATUS_MESSAGE="✅ Білд завершився успішно."
else
    BUILD_STATUS_MESSAGE="❌ Білд завершився з помилкою."
fi

MESSAGE="🔔 Jenkins Build Notification 🔔
*Status:* ${BUILD_STATUS_MESSAGE}
-------------------------------------------
*Job Name:* ${JOB_NAME}
*Build Number:* ${BUILD_NUMBER}
*Commit:* ${GIT_COMMIT}
*Repository:* ${GIT_URL}
*Build URL:* ${BUILD_URL}"

curl --location "https://api.telegram.org/bot${telegram_api}/sendMessage" \
--form "text=${MESSAGE}" \
--form "chat_id=${client_id}" \
--form "parse_mode=Markdown"
```

За допомогою `set +e` я забезпечую відправлення повідомлення навіть у випадку помилки. Скрипт аналізує вивід команди `mvn` для визначення статусу білду, формує повідомлення та надсилає його за допомогою `curl` з використанням параметрів `telegram_api` та `client_id`.

![image](https://github.com/user-attachments/assets/cbd5f351-259f-42fc-afe4-10aedc405df9)

### Stage: Deploy

```bash
set +e

REMOTE_USER=ubuntu
REMOTE_HOST=44.200.11.223
DST_FOLDER=/home/ubuntu/app
PORT=8080
URL=http://$REMOTE_HOST:$PORT

ssh -o StrictHostKeyChecking=no $REMOTE_USER@$REMOTE_HOST "mkdir -p $DST_FOLDER"
scp -o StrictHostKeyChecking=no -r initial/target/*.jar $REMOTE_USER@$REMOTE_HOST:$DST_FOLDER
ssh -o StrictHostKeyChecking=no $REMOTE_USER@$REMOTE_HOST "cd $DST_FOLDER && nohup java -jar *.jar > app.log 2>&1 & exit"

response=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 $URL)

if [ "$response" -eq 200 ]; then
    STATUS="✅ Аплікація працює на $URL"
else
    STATUS="❌ Аплікація НЕ працює на $URL. Код помилки: $response"
fi

curl --location "https://api.telegram.org/bot${telegram_api}/sendMessage" \
--form "text=${STATUS}" \
--form "chat_id=${client_id}"
```

Цей скрипт виконує наступні дії:
- Створює директорію на віддаленому сервері (якщо вона ще не існує).
- Передає JAR-файл через `scp` до вказаної папки.
- Запускає аплікацію за допомогою `nohup java -jar`, щоб процес залишався активним після виходу з SSH-сесії.
- Перевіряє доступність аплікації за допомогою `curl` із таймаутом 10 секунд.
- Відправляє повідомлення в Telegram з використанням `telegram_api` та `client_id`.

Якщо сервер відповідає кодом 200, повідомлення містить інформацію про успішний запуск.

![image](https://github.com/user-attachments/assets/afbd2979-4c58-4e9f-9cb8-bd7d4b86974d)

Інакше надсилається повідомлення про помилку з HTTP-кодом відповіді.

![image](https://github.com/user-attachments/assets/95e2cc9e-55ca-4cd0-b29a-8a87491aed5e)
