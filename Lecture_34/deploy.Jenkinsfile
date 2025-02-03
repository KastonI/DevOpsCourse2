pipeline {
    agent any

    parameters {
        string(name: 'REMOTE_USER', defaultValue: 'ubuntu', description: 'Remote server user')
        string(name: 'REMOTE_HOST', defaultValue: '44.200.11.223', description: 'Remote server address')
        string(name: 'DST_FOLDER', defaultValue: '/home/ubuntu/app', description: 'Destination folder on the server')
    }

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
    }
}
