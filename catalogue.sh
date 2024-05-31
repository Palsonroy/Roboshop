#!/bin/bash
ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

MONGODB_HOST=mongodb.daws66s.online
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started excuting at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){

    if [ $1 -ne 0 ]
    then 
        echo -e "$2 ... $2 failed $N" 
        exit 1
    else
        echo -e "$2 ...$G success $N"
    fi
}
if [ $ID -ne 0 ]
    then 
        echo -e "$R ERROR : run with root access $N"
        exit 1
    else
        echo " you are root user"
fi 

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "Disabling current nodejs" 

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "Enabling NodeJs:18" 

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "installing nodejs:18"

useradd roboshop &>> LOGFILE

VALIDATE $? "creating roboshop user" 

mkdir /app &>> $LOGFILE

VALIDATE $? "creating roboshop user" 

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? "downloading catalogue application"

cd /app &>> $LOGFILE

unzip /tmp/catalogue.zip &>> $LOGFILE

VALIDATE $? "uzipping catalogue application" 

npm install &>> $LOGFILE

VALIDATE $? "installing dependencies" 

cp /home/centos/roboshop/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? "copying catalogue service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "catalogue deamon reload" 

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "catalogue enabled"  

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "catalogue started" &>> $LOGFILE

cp /home/centos/roboshop/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "copying mongorepo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "copying mongorepo client"

mongo --host $MONGODB_HOST </app/schema/catalogue.js

VALIDATE $? "loading catalogue data into mongodb"