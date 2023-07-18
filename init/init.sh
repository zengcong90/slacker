#!/bin/bash

yum -y install wget

FILE=/usr/local/slacker.tar
if [[ ! -f $FILE ]];then
    cd /usr/local
    `wget ftp://zengcong@192.168.0.51/home/tools/slacker.tar --ftp-password=Zc134250.`
    tar xvf /usr/local/slacker.tar
    cd ./slacker
    source ./install.sh
fi