#!/bin/bash
ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
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
cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "copied mongodb Repo"

dnf install mongodb-org -y &>> $LOGFILE

VALIDATE $? "Installing MongoDB" 

systemctl enable mongod &>> $LOGFILE

VALIDATE $? "MongoDB Enabled" 

systemctl start mongod &>> $LOGFILE

VALIDATE $? "MongoDB Started" 

sed -i 's/127.0.0.0/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE

VALIDATE $? "remote access to mongodb"

systemctl restart mongod &>> $LOGFILE

VALIDATE $? "Restarting MongoDb"