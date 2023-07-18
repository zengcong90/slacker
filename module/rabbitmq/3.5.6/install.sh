#!/bin/bash
#
# Module: RABBITMQ
# Version: 3.5.6
#
# Author:  zengcong
# Website:  http://zsxhkj.com
#

install_rabbitmq()
{
    . $IN_PWD/GLOBAL.conf
    . $IN_PWD/utils/helper.sh
    . $IN_PWD/utils/installer.sh 
    cd $INSTALL_SRC_PATH/
#判断unixODBC-2.2.1安装包存在
UFILE=$INSTALL_SRC_PATH/rabbitmq-server-generic-unix-3.5.6.tar.gz
if [[ -f "$UFILE" ]]; then
    echo "$UFILE exist"
else
    `wget $FTPURL/rabbitmq-server-generic-unix-3.5.6.tar.gz --ftp-password=Zc134250.`
fi
#解压断rabbitmq安装包
tar -zxvf rabbitmq-server-generic-unix-3.5.6.tar.gz
mv $INSTALL_SRC_PATH/rabbitmq_server-3.5.6  $MOD_RABBITMQ_INSTALL_PATH
cd $MOD_RABBITMQ_INSTALL_PATH
mv $MOD_RABBITMQ_INSTALL_PATH/etc/rabbitmq/rabbitmq.config.example $MOD_RABBITMQ_INSTALL_PATH/etc/rabbitmq/rabbitmq.config

#设置rabbitmq系统环境变量
if [ 0"$RABBITMQ_HOME" = "0" ];then
    echo "export RABBITMQ_HOME=$MOD_RABBITMQ_INSTALL_PATH" >> /etc/profile
    echo "export PATH=\$PATH:\$RABBITMQ_HOME/sbin" >> /etc/profile
        . /etc/profile
fi
RBS=/usr/lib/systemd/system/rabbitmq.service
if [[ -f "$RBS" ]]; then
    echo "$RBS exist"
else
touch $RBS
cat >>/usr/lib/systemd/system/rabbitmq.service<<EOF
[Unit]
Description=rabbitmq
After=network.target
[Service]
Environment="HOME=/opt/slacker/bin/erlang/bin"
WorkingDirectory=$RABBITMQ_HOME
ExecStart=$RABBITMQ_HOME/sbin/rabbitmq-server start
ExecStop=$RABBITMQ_HOME/sbin/rabbitmqctl stop
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
fi

systemctl daemon-reload
systemctl enable rabbitmq
systemctl is-enabled rabbitmq

# 创建rabbitmq用户账号
cd /opt/slacker/bin/rabbitmq/sbin
echo "cd /opt/slacker/bin/rabbitmq/sbin"
./rabbitmq-server -detached
./rabbitmq-plugins enable rabbitmq_management  
./rabbitmqctl start_app  
./rabbitmqctl add_user admin 123456  
./rabbitmqctl set_user_tags admin administrator 
./rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"

if [ -d "$MOD_RABBITMQ_INSTALL_PATH" ];then
    echo -e "\033[32mMONGODB install successfully! \033[0m"
else
    echo -e "\033[31mMONGODB install failed, Please contact the author! \033[0m"
    kill -9 $$
fi
    # ============================

    printf "

RABBITMQ Install Information
=========================
RABBITMQ Version: 17.5
RABBITMQ Install Path: $MOD_RABBITMQ_INSTALL_PATH
Created: `date`
-------------------------
 "
    # ============================
}
