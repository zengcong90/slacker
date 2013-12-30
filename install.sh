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

# Init Environment
. $IN_PWD/options.conf
. $IN_PWD/func/check_os.sh

if [ -d "$IN_PWD/src/" ];then
    cp -fr $IN_PWD/src/*.* $INSTALL_PATH/src/
fi
chmod +x $IN_PWD/func/*.sh $IN_PWD/module/* $IN_PWD/*.sh

if [ "$OS" == 'CentOS' ];then
    if [ -s "$IN_PWD/func/init.sh" ];then
        . $IN_PWD/func/init.sh 2>&1 | tee -a $INSTALL_PATH/install.log
        /bin/mv $IN_PWD/func/init.sh $IN_PWD/func/init.ed
    fi
    [ ! -z "`gcc --version | head -n1 | grep 4\.1`" ] && export CC="gcc44" CXX="g++44"
else
    echo -e "\033[31mDoes not support this OS, Please contact the author! \033[0m"
    kill -9 $$
fi

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
if [ -s "$IN_PWD/module/mysql.sh" ];then
    . $IN_PWD/module/mysql.sh
    Install_MySQL 2>&1 | tee -a $INSTALL_PATH/install.log
    /bin/mv $IN_PWD/module/mysql.sh $IN_PWD/module/mysql.ed
fi

# PHP
if [ -s "$IN_PWD/module/php.sh" ];then
    . $IN_PWD/module/php.sh
    Install_PHPNeeds 2>&1 | tee -a $INSTALL_PATH/install.log
    Install_PHP 2>&1 | tee -a $INSTALL_PATH/install.log
    # Install_PHPExtends 2>&1 | tee -a $INSTALL_PATH/install.log
    # /bin/mv $IN_PWD/module/php.sh $IN_PWD/module/php.ed
fi

# Nginx
if [ -s "$IN_PWD/module/nginx.sh" ];then
    . $IN_PWD/module/nginx.sh
    Install_Nginx 2>&1 | tee -a $INSTALL_PATH/install.log
    /bin/mv $IN_PWD/module/nginx.sh $IN_PWD/module/nginx.ed
fi

# phpMyAdmin
if [ -s "$IN_PWD/module/phpmyadmin.sh" ];then
    . $IN_PWD/module/phpmyadmin.sh
    Install_PhpMyAdmin 2>&1 | tee -a $INSTALL_PATH/install.log
    /bin/mv $IN_PWD/module/phpmyadmin.sh $IN_PWD/module/phpmyadmin.ed
fi
