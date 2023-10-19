#!/bin/bash
#
# Module: zookeeper
# Version: 3.4.10
#
# Author:  zengcong
# Website:  http://zsxhkj.com
#

install_zookeeper()
{
    . $IN_PWD/GLOBAL.conf
    . $IN_PWD/utils/helper.sh
    . $IN_PWD/utils/installer.sh 
    cd $INSTALL_SRC_PATH/
    FILE=$INSTALL_SRC_PATH/zookeeper-3.4.10.tar.gz
    if [[ -f "$FILE" ]]; then
        echo "$FILE exist"
    else
        `wget $FTPURL/zookeeper-3.4.10.tar.gz --ftp-password=Zc134250.`
    fi
    tar -zxvf zookeeper-3.4.10.tar.gz
    mv $INSTALL_SRC_PATH/zookeeper-3.4.10  $MOD_ZOOKEEPER_INSTALL_PATH
    if [ ! -d "$MOD_ZOOKEEPER_INSTALL_PATH/data" ];then
        mkdir $MOD_ZOOKEEPER_INSTALL_PATH/data
    fi
    if [  -f "$MOD_ZOOKEEPER_INSTALL_PATH/conf/zoo_sample.cfg" ];then
       mv $MOD_ZOOKEEPER_INSTALL_PATH/conf/zoo_sample.cfg $MOD_ZOOKEEPER_INSTALL_PATH/conf/zoo.cfg
       sed -i "s@^dataDir=/tmp/zookeeper@dataDir=$MOD_ZOOKEEPER_INSTALL_PATH/data@"  $MOD_ZOOKEEPER_INSTALL_PATH/conf/zoo.cfg
    fi
    if [  -f "$MOD_ZOOKEEPER_INSTALL_PATH/bin/zkEnv.sh" ];then
       sed -i "s@^ export JAVA_HOME=@ export JAVA_HOME=/opt/slacker/bin/jdk@"  $MOD_ZOOKEEPER_INSTALL_PATH/bin/zkEnv.sh
    fi
    ZKS=/usr/lib/systemd/system/zookeeper.service
    if [ ! -f "$ZKS" ]; then
    sed -i "s@^# a sibling of this script's directory@# a sibling of this script's directory\\n export JAVA_HOME=$JAVA_HOME@" $MOD_ZOOKEEPER_INSTALL_PATH/bin/zkEnv.sh
        touch $ZKS
        echo  "[Unit]" >> $ZKS
        echo  "Description=zookeeper" >> $ZKS
        echo  "After=network.target remote-fs.target nss-lookup.target" >> $ZKS
        echo  "ConditionPathExists=/opt/slacker/bin/zookeeper/conf/zoo.cfg" >> $ZKS
        echo  "[Service]" >> $ZKS
        echo  "Type=forking" >> $ZKS
        echo  "User=root" >> $ZKS
        echo  "Group=root" >> $ZKS
        echo  "ExecStart=/opt/slacker/bin/zookeeper/bin/zkServer.sh start" >> $ZKS
        echo  "ExecReload=/opt/slacker/bin/zookeeper/bin/zkServer.sh restart" >> $ZKS
        echo  "ExecStop=/opt/slacker/bin/zookeeper/bin/zkServer.sh stop" >> $ZKS 
        echo  "[Install]" >> $ZKS 
        echo  "WantedBy=multi-user.target" >> $ZKS     
        chmod 777 $ZKS
        systemctl daemon-reload
        systemctl enable zookeeper
        systemctl is-enabled zookeeper
    fi
    # ============================

    printf "

ZOOKEEPER Install Information
=========================
ZOOKEEPER Version: 3.4.10
ZOOKEEPER Install Path: $MOD_ZOOKEEPER_INSTALL_PATH
Created: `date`
-------------------------
 "
    # ============================
}
