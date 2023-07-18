#!/bin/bash
#
# Module: MONGODB
# Version: 4.0.0
#
# Author:  zengcong
# Website:  http://zsxhkj.com
#

install_mongodb()
{
    . $IN_PWD/GLOBAL.conf
    . $IN_PWD/utils/helper.sh
    . $IN_PWD/utils/installer.sh 
    cd $INSTALL_SRC_PATH/
 #判断mongodb安装包存在
    FILE=$INSTALL_SRC_PATH/mongodb-linux-x86_64-4.0.0.tgz
    
    if [[ -f "$FILE" ]]; then
        echo "$FILE exist"
    else
        `wget $FTPURL/mongodb-linux-x86_64-4.0.0.tgz --ftp-password=Zc134250.`
    fi
#解压断mongodb安装包
    tar -zxvf mongodb-linux-x86_64-4.0.0.tgz
    mv $INSTALL_SRC_PATH/mongodb-linux-x86_64-4.0.0  $MOD_MONGODB_INSTALL_PATH
    cd $MOD_MONGODB_INSTALL_PATH

#创建mongodb日志和数据文件夹
    mkdir -p $MOD_MONGODB_DATA_PATH $MOD_MONGODB_DATA_PATH/db $MOD_MONGODB_LOG_PATH 
#创建mongodb日志文件
    LOGFILE=$MOD_MONGODB_LOG_PATH/mongodb.log
    if [[ ! -f "$LOGFILE" ]];then
      touch $LOGFILE
    fi
#设置mongodb系统环境变量
    if [ 0"$MONGODB" = "0" ];then
		echo "export MONGODB_HOME=$MOD_MONGODB_INSTALL_PATH" >> /etc/profile
	    echo "export PATH=\$PATH:\$MONGODB_HOME/bin" >> /etc/profile
	     . /etc/profile
    fi
#设置mongodb参数文件
    MONGODB_CONF=/etc/mongodb.conf 
    if [[ ! -f "$MONGODB_CONF" ]];then
       touch $MONGODB_CONF
       echo "#指定数据库路径" >> $MONGODB_CONF
       echo "dbpath=$MOD_MONGODB_DATA_PATH" >> $MONGODB_CONF
       echo "#指定MongoDB日志文件" >> $MONGODB_CONF
       echo "logpath=$LOGFILE" >> $MONGODB_CONF
       echo "# 使用追加的方式写日志" >> $MONGODB_CONF
       echo "logappend=true" >> $MONGODB_CONF
       echo "#端口号" >> $MONGODB_CONF
       echo "port=27017" >> $MONGODB_CONF
       echo "#方便外网访问" >> $MONGODB_CONF
       echo "bind_ip=0.0.0.0" >> $MONGODB_CONF
       echo "fork=true # 以守护进程的方式运行MongoDB\，创建服务器进程" >> $MONGODB_CONF
       echo "#auth=true #启用用户验证" >> $MONGODB_CONF
    fi

#启动mongodb
  mongod -f /etc/mongodb.conf
#创建账号
  mongo localhost:27017/admin --eval "printjson(db.createUser({user: \"root\", pwd: \"123456\", roles: [{role: \"root\", db: \"admin\"}]}))"
  echo "---------mongodb create user  success!!!---------"
#创建mongodb systemctl启动文件  
    MGF=/usr/lib/systemd/system/mongodb.service
    if [[ ! -f "$MGF" ]];then
        touch $MGF
        chmod 755 $MGF
        echo  "[Unit]" >> $MGF
        echo  "Description=mongodb" >> $MGF
        echo  "After=network.target remote-fs.target nss-lookup.target" >> $MGF
        echo  "[Service]" >> $MGF    
        echo  "ExecStart=$MOD_MONGODB_INSTALL_PATH/bin/mongod -f /etc/mongodb.conf " >> $MGF 
        echo  "PermissionsStartOnly=true" >> $MGF 
        echo  "PrivateTmp=true" >> $MGF 
        echo  "Type=forking" >> $MGF
        echo  "LimitCPU=infinity" >> $MGF
        echo  "LimitAS=infinity" >> $MGF
        echo  "LimitNOFILE=64000" >> $MGF
        echo  "LimitNPROC=64000" >> $MGF
        echo  "LimitMEMLOCK=infinity" >> $MGF
        echo  "TasksMax=infinity" >> $MGF
        echo  "TasksAccounting=false" >> $MGF
        echo  "Restart=on-abort" >> $MGF
        echo  "RestartSec=5s" >> $MGF
        echo  "User=root" >> $MGF
        echo  "Group=root" >> $MGF
        echo  "[Install]" >> $MGF 
        echo  "WantedBy=multi-user.target" >> $MGF     
        systemctl daemon-reload
        systemctl enable mongodb
        systemctl is-enabled mongodb
    fi

    if [ -d "$MOD_MONGODB_INSTALL_PATH" ];then
        echo -e "\033[32mMONGODB install successfully! \033[0m"
    else
        echo -e "\033[31mMONGODB install failed, Please contact the author! \033[0m"
        kill -9 $$
    fi
    # ============================

    printf "

MONGODB Install Information
=========================
MONGODB Version: 4.0.0
MONGODB Install Path: $MOD_MONGODB_INSTALL_PATH
Created: `date`
-------------------------
 "
    # ============================
}
