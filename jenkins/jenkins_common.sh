#!/bin/bash
#==========================
# This is just a reminder for Jenkins usage
# Author Artyom Ivanov
# Created at 10.2022
# Version 1.0
#==========================

# nice working roadmap is looks like follows
# github repository with apt key or ssh key
# jenkins with ssh key, published to internet via some port
# configured webhook on github so it can trigger job on jenkins on main commit
# jenkins got github module installed, aws module installed
# create an aws user\token with required rights
# create an aws application with ha?
# creat jenkins job with webhook to github

# installation
sudo apt update
sudo apt install openjdk-11-jre
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins

# after installation go to http://serverip:8080 to unblock installation
# The command: sudo cat /var/lib/jenkins/secrets/initialAdminPassword will print the password at console.


# Для тех у кого проблемы с SSH ключами и Jenkins Master не коннектится к slave-машине:
# 1.На виртуалке, как сказал Денис обязательно должна быть java и ssh (можно установить через apt install default-jre, если версии разные, то установить нужную и apt install ssh, убедиться, что ssh работает - systemctl status ssh, должен быть active)
# 2. На slave машине у текущего пользователя геренируем ключи:
# ssh-keygen (в результате будет 2 ключа id_rsa - приватный и id_rsa.pub - публичный)
# 3. Нужно скопировать приватный ключ и вставить его в настройки slave на Jenkins мастере:
# cd ~/.ssh; cat id_rsa (ну и скопировать его)
# 4. Теперь добавить публичный ключ id_rsa.pub в authorized_keys:
# cat id_rsa.pub > authorized_keys
# 5. Все теперь Jenkins Master сможет подключиться к slave-машине

# create a user
# create a token inside a user
# install a java on a source mashine
export JENKINS_USER_ID=mynewuser
export JENKINS_API_TOKEN=115e1f924d3777758af7269b7068aa643c
java -jar jenkins-cli.jar -s http://someip:8080 who-am-i

# create a token Jenkins->User->Settings->Token
# and use it with username to trigger build task
http://someuser:sometokensomeip:8080/job/Build_Auto_bytrigger/build?token=Build_Auto_By_link

# jenkins groovy scripts
println("Hello mallo")
# run command on host system
"ls -la".execute().text
# // - comment on groovy script
# cat local file
new File ('/etc/passwd').text
# another cat local file
new File("${Jenkins.instance.root}/credentials.xml").text
# list all possible commands
Jenkins.instance.metaClass.methods*.name
# get executors number
Jenkins.instance.getNumExecutors()
# set number of executors to 6
Jenkins.instance.setNumExecutors(6)
# get build results
job = Jenkins.instance.getItemByFullName("Build_Auto_bytrigger")
job.getBuilds()
job.getBuilds().each {
  println("Build " + it + " Results " + it.result)
}
# remove succesfull builds
job = Jenkins.instance.getItemByFullName("Build_Auto_bytrigger")
job.getBuilds().each {
	if (it.result == Result.SUCCESS) {
		it.delete()
	}
}
# remove all jobs
job = Jenkins.instance.getItemByFullName("Build_Auto_bytrigger")
job.builds.each() { build ->
  build.delete()
}
job.updateNextBuildNumber(1)


# jenkins pipelines
# install modules pipeline, docker pipeline, pipeline api
# pipeline roadmap as this:
# create git repository, place jenkinsfile in this repository
# create pipeline to clone repository and run a jenkinsfile
# profit
# example 1, simple
pipeline {
    agent any
    
    environment {
        PROJECT_NAME = "testing"
        OWNER_NAME = "winadm87"
        
    }

    stages {
        stage('Hello') {
            steps {
                echo 'Hello World'
                echo "Starting project ${PROJECT_NAME}"
            }
        }
        stage('Proceed') {
            steps {
                echo 'Proceed'
                sh   "ls -al /home/"
            }
        }
        stage('Finish') {
            steps {
                echo 'Finished'
                sh '''
                echo 1
                echo 2
                echo 3
                '''
            }
        }
    }
}

# example 2 with docker
pipeline {
    agent { docker { image 'python:latest' } }

    stages {
        stage('Hello') {
            steps {
                echo 'Hello World'
                //sh "whoami"
            }
        }
        stage('Proceed') {
            steps {
                echo 'Proceed'
                sh   "ls -al /home/"
            }
        }
        stage('Finish') {
            steps {
                echo 'Finished'
                sh '''
                echo 1
                echo 2
                echo 3
                '''
                sh  "python --version"
            }
        }
    }
}
