#!/bin/bash
# Author:  Allen <movoin@gmail.com>
# Website:  http://movoin.com
#
# Notes: LNMP for CentOS/RadHat 5+
#

IN_PWD=$(pwd)

# Check if user is root
[ $(id -u) != "0" ] && echo "Error: You must be root to run this script" && exit 1

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear

. $IN_PWD/GLOBAL.conf
. $IN_PWD/utils/helper.sh
. $IN_PWD/utils/installer.sh

# Local IP Address
MYIPADDR=`ifconfig|grep 'inet addr:'|grep -v '127.0.0.1'|cut -d: -f2 |awk '{ print $1}'`

if [ -f /etc/redhat-release ];then
    printf "
################################################################################
                             SLACKER V$SLACKER_VERSION
             AUTHOR: Allen <movoin@gmail.com> UPDATE: $SLACKER_UPDATED
                         - WEBSITE: http://movoin.com -
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


# Database
if [ ! $MOD_DB == '' ] && [ ! $MOD_DB_VER == '' ];then
    install_mod $MOD_DB $MOD_DB_VER
fi


# Web Server
if [ ! $MOD_WEB == '' ] && [ ! $MOD_WEB_VER == '' ];then
    install_mod $MOD_WEB $MOD_WEB_VER
fi


# PHP
if [ ! $MOD_PHP == '' ] && [ ! $MOD_PHP_VER == '' ];then
    install_mod $MOD_PHP $MOD_PHP_VER
fi


# PHP Extensions

# - imagick
if [ $EXT_IMAGICK_INSTALL == 'y' ];then
    install_php_extend 'imagick'
fi

# - memcached
if [ $EXT_MEMCACHED_INSTALL == 'y' ];then
    install_php_extend 'memcached'
fi

# - hidef
if [ $EXT_HIDEF_INSTALL == 'y' ];then
    install_php_extend 'hidef'
fi

# - pecl_http
if [ $EXT_PECL_HTTP_INSTALL == 'y' ];then
    install_php_extend 'pecl_http'
fi

# - xdebug
if [ $EXT_XDEBUG_INSTALL == 'y' ];then
    install_php_extend 'xdebug'
fi

# - pthreads
if [ $EXT_PTHREADS_INSTALL == 'y' ];then
    install_php_extend 'pthreads'
fi


# PHP Libraries
if [ $LIB_PHPMYADMIN_INSTALL == 'y' ];then
    install_php_library 'phpmyadmin'
fi

# Show Install Success Infomations
cat $INSTALL_PATH/install.info
