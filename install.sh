#!/bin/bash
# Author:  zengcong
# Website:  http://www.zsxhkj.com
#
# Notes: LNMP for CentOS/RadHat 5+
#

IN_PWD=$(pwd)

# Check if user is root
[ $(id -u) != "0" ] && echo "Error: You must be root to run this script" && exit 1

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear

. $IN_PWD/VERSION.conf
. $IN_PWD/GLOBAL.conf
. $IN_PWD/utils/helper.sh
. $IN_PWD/utils/installer.sh

# Local IP Address
MYIPADDR=`ifconfig|grep 'inet addr:'|grep -v '127.0.0.1'|cut -d: -f2 |awk '{ print $1}'`

if [ -f /etc/redhat-release ];then
    printf "
################################################################################
                             SLACKER V$SLACKER_VERSION
             AUTHOR: zengcong  UPDATE: $SLACKER_UPDATED
                         - WEBSITE: http://www.zsxhkj.com -
################################################################################

"
else
    echo -e "\033[31mDoes not support this OS, Please contact the author! \033[0m"
    kill -9 $$
fi

# Definition Directory
mkdir -p $INSTALL_BACKUP_PATH \
    $INSTALL_BIN_PATH \
    $INSTALL_DATA_PATH \
    $INSTALL_LIB_PATH \
    $INSTALL_LOGS_PATH \
    $INSTALL_SRC_PATH \
    $INSTALL_WWW_PATH

chmod +x $IN_PWD/init/*.sh $IN_PWD/utils/*.sh $IN_PWD/*.sh

# Init Environment
install_shell $IN_PWD/init/CentOS.sh

# Optimization compiled code using safe, sane CFLAGS and CXXFLAGS
if [ "$IS_GCC_SANE" == 'y' ];then
    if [ `getconf WORD_BIT` == 32 ] && [ `getconf LONG_BIT` == 64 ];then
        export CHOST="x86_64-pc-linux-gnu" CFLAGS="-march=native -O3 -pipe -fomit-frame-pointer"
        export CXXFLAGS="${CFLAGS}"
    elif [ `getconf WORD_BIT` == 32 ] && [ `getconf LONG_BIT` == 32 ];then
        export CHOST="i686-pc-linux-gnu" CFLAGS="-march=native -O3 -pipe -fomit-frame-pointer"
        export CXXFLAGS="${CFLAGS}"
    fi
fi


# jdk
if [ ! $MOD_JDK == '' ] && [ ! $MOD_JDK_VER == '' ];then
    install_mod $MOD_JDK  $MOD_JDK_VER
fi
# maven
if [ ! $MOD_MAVEN == '' ] && [ ! $MOD_MAVEN_VER == '' ];then
    install_mod $MOD_MAVEN  $MOD_MAVEN_VER
fi
# mysql
if [ ! $MOD_MYSQL == '' ] && [ ! $MOD_MYSQL_VER == '' ];then
    install_mod $MOD_MYSQL  $MOD_MYSQL_VER
fi
# zookeeper
if [ ! $MOD_ZOOKEEPER == '' ] && [ ! $MOD_ZOOKEEPER_VER == '' ];then
    install_mod $MOD_ZOOKEEPER  $MOD_ZOOKEEPER_VER
fi
# tocmat
if [ ! $MOD_TOMCAT == '' ] && [ ! $MOD_TOMCAT_VER == '' ];then
    install_mod $MOD_TOMCAT  $MOD_TOMCAT_VER
fi
# redis
if [ ! $MOD_REDIS == '' ] && [ ! $MOD_REDIS_VER == '' ];then
    install_mod $MOD_REDIS  $MOD_REDIS_VER
fi

# mongodb
if [ ! $MOD_MONGODB == '' ] && [ ! $MOD_MONGODB_VER == '' ];then
    install_mod $MOD_MONGODB  $MOD_MONGODB_VER
fi
# erlang
if [ ! $MOD_ERLANG == '' ] && [ ! $MOD_ERLANG_VER == '' ];then
    install_mod $MOD_ERLANG  $MOD_ERLANG_VER
fi
# rabbitmq
if [ ! $MOD_RABBITMQ == '' ] && [ ! $MOD_RABBITMQ_VER == '' ];then
    install_mod $MOD_RABBITMQ  $MOD_RABBITMQ_VER
fi

source /etc/profile
echo "source /etc/profile Success"
# Show Install Success Infomation
cat $INSTALL_PATH/install.info

# Reboot OS
while :
do
    echo
    echo -e "\033[31mPlease restart the server and see if the services start up fine.\033[0m"
    read -p "Do you want to restart OS ? [y/n]: " IS_RESTART_OS
    if [ "$IS_RESTART_OS" != 'y' -a "$IS_RESTART_OS" != 'n' ];then
        echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
    else
        break
    fi
done
[ "$IS_RESTART_OS" == 'y' ] && reboot
