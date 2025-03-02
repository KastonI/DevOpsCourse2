# **Jenkins**

## **Jenkins Deployment**

Using **Terraform**, I launched two instances:
- One for **Jenkins** itself.
- Another for deploying the application.

Using **Ansible**, I installed Jenkins and manually added the required plugins via the UI. Additionally, I connected via SSH to install necessary packages like `openjdk-17-jdk` and `maven`.

### **Additional Configurations:**
- **Added SSH keys** for accessing my **GitHub repository**.
- **Added another SSH key** for accessing the **EC2 instance** where the application will be deployed.

### **Telegram Notification Setup**
For sending notifications, I added:
- A **secret text** credential (`telegram_api`) in Jenkins.
- Another **credential** (`client_id`) containing my **Telegram chat ID**.

---

## **EC2 Setup for Deployment**
I connected to the EC2 instance and installed `openjdk-17-jdk` to support **Spring Boot**.

---

## **Configuring a Freestyle Job**

I first set up **SSH credentials** for accessing the **GitHub repository**.  
Then, I enabled **secrets usage** in the pipeline and configured `ssh-agent` for accessing EC2.

### **Build & Deploy Stages**

#### **Build Stage**
```bash
set +e

cd initial
mvn clean install
BUILD_STATUS=$?

if [ $BUILD_STATUS -eq 0 ]; then
    echo "✅ Build completed successfully."
else
    echo "❌ Build failed."
fi
```

#### **Deployment Stage**
```bash
REMOTE_USER=ubuntu
REMOTE_HOST=44.200.11.223
DST_FOLDER=/home/ubuntu/app

ssh -o StrictHostKeyChecking=no $REMOTE_USER@$REMOTE_HOST "mkdir -p $DST_FOLDER"
scp -o StrictHostKeyChecking=no -r initial/target/*.jar $REMOTE_USER@$REMOTE_HOST:$DST_FOLDER
ssh -o StrictHostKeyChecking=no $REMOTE_USER@$REMOTE_HOST "cd $DST_FOLDER && nohup java -jar *.jar > app.log 2>&1 & exit"
```

### **Testing the Application**
After deployment, the application can be tested using:

```bash
curl http://44.200.11.223:8080
```

✅ **Expected Response:**
```
Greetings from Spring Boot!
```

---

## **Creating a Jenkinsfile**

I created a **`deploy.Jenkinsfile`** to automate the process.

### **Pipeline Parameters**
```groovy
pipeline {
    agent any

    parameters {
        string(name: 'REMOTE_USER', defaultValue: 'ubuntu', description: 'User for SSH')
        string(name: 'REMOTE_HOST', defaultValue: '44.200.11.223', description: 'Target EC2 instance')
        string(name: 'DST_FOLDER', defaultValue: '/home/ubuntu/app', description: 'Deployment folder')
    }
}
```

### **Build Stage**
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
                echo "Building project..."
                sh 'cd initial && mvn clean install'
            }
        }
    }
}
```

### **Deploy to EC2**
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

✅ **Successful pipeline execution:**
![image](https://github.com/user-attachments/assets/f4d9a3a2-1ac9-4c2e-a8cd-9cd27c8eec25)

---

## **Telegram Notifications Setup**

I initially tried multiple Jenkins plugins, but:
- One plugin was outdated and lacked support for newer Jenkins versions.
- Another failed to send messages despite multiple configuration attempts.
- A third required an **external service**, but was unreliable.

💡 **Solution:** Use **`curl` requests** inside a **Freestyle Job**.

---

### **Telegram Notification - Build Stage**
```bash
set +e

cd initial
mvn clean install
BUILD_STATUS=$?

if [ $BUILD_STATUS -eq 0 ]; then
    BUILD_STATUS_MESSAGE="✅ Build successful."
else
    BUILD_STATUS_MESSAGE="❌ Build failed."
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

### **Explanation**
- `set +e` ensures that the message is **sent even if the build fails**.
- The script **checks the Maven build status**, formats a message, and **sends it via Telegram API**.

✅ **Telegram Notification Example:**
![image](https://github.com/user-attachments/assets/cbd5f351-259f-42fc-afe4-10aedc405df9)

---

### **Telegram Notification - Deploy Stage**
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
    STATUS="✅ Application is running at $URL"
else
    STATUS="❌ Application FAILED to start at $URL. HTTP Error: $response"
fi

curl --location "https://api.telegram.org/bot${telegram_api}/sendMessage" \
--form "text=${STATUS}" \
--form "chat_id=${client_id}"
```

### **Explanation**
- The script:
  1. **Creates the remote directory** (if it doesn’t exist).
  2. **Transfers the JAR file** using `scp`.
  3. **Runs the application** using `nohup`.
  4. **Checks if the application is running** using `curl`.
  5. **Sends a Telegram notification**.

✅ **Successful Deployment Notification:**
![image](https://github.com/user-attachments/assets/afbd2979-4c58-4e9f-9cb8-bd7d4b86974d)

❌ **Failure Notification (Application not responding):**
![image](https://github.com/user-attachments/assets/95e2cc9e-55ca-4cd0-b29a-8a87491aed5e)