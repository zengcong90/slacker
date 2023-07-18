#!/bin/bash
#
# Module: REDIS
# Version: 6.0.1
#
# Author:  zengcong
# Website:  http://zsxhkj.com
#

install_redis()
{
    . $IN_PWD/GLOBAL.conf
    . $IN_PWD/utils/helper.sh
    . $IN_PWD/utils/installer.sh 
    cd $INSTALL_SRC_PATH/
    FILE=$INSTALL_SRC_PATH/redis-4.0.10.tar.gz
    if [[ -f "$FILE" ]]; then
        echo "$FILE exist"
    else
        `wget $FTPURL/redis-4.0.10.tar.gz --ftp-password=Zc134250.`
    fi
    tar -zxvf redis-4.0.10.tar.gz
    mv $INSTALL_SRC_PATH/redis-4.0.10  $MOD_REDIS_INSTALL_PATH
    cd $MOD_REDIS_INSTALL_PATH 
    make MALLOC=libc
    cd src && make install
    RDF=$MOD_REDIS_INSTALL_PATH/redis.conf
    if [ -f "$RDF" ]; then
        sed -i "s@^bind 127.0.0.1@#bind 127.0.0.1@" $RDF
        sed -i "s@^daemonize no@daemonize yes@" $RDF
        sed -i "s@^protected-mode yes@protected-mode no@" $RDF
    fi
    RDS=/usr/lib/systemd/system/redis.service
    if [ ! -f "$RDS" ]; then
        touch $RDS
        echo  "[Unit]" >> $RDS
        echo  "Description=redis" >> $RDS
        echo  "After=network.target remote-fs.target nss-lookup.target" >> $RDS
        echo  "[Service]" >> $RDS  
        echo  "WorkingDirectory=$MOD_REDIS_INSTALL_PATH" >> $RDS 
        echo  "PIDFile=/var/run/redis_6379.pid" >> $RDS 
        echo  "ExecStart=$MOD_REDIS_INSTALL_PATH/src/redis-server $MOD_REDIS_INSTALL_PATH/redis.conf" >> $RDS 
        echo  "ExecReload=/bin/kill -s HUP \$MAINPID" >> $RDS 
        echo  "ExecStop=/bin/kill -s QUIT \$MAINPID" >> $RDS 
        echo  "PrivateTmp=true" >> $RDS 
        echo  "Type=forking" >> $RDS
        echo  "[Install]" >> $RDS 
        echo  "WantedBy=multi-user.target" >> $RDS     
        chmod 777 $RDS
        systemctl daemon-reload
        systemctl enable redis
        systemctl is-enabled redis
    fi
    # ============================

    printf "

REDIS Install Information
=========================
REDIS Version: 6.0.1
REDIS Install Path: $MOD_REDIS_INSTALL_PATH
Created: `date`
-------------------------
 "
    # ============================
}
