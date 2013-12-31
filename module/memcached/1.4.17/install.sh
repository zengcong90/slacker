#!/bin/bash
#
# Module: Memcached
# Version: 1.4.17
#
# Author:  Allen <movoin@gmail.com>
# Website:  http://movoin.com
#

install_memcached()
{
    . $IN_PWD/GLOBAL.conf
    . $IN_PWD/utils/helper.sh
    . $IN_PWD/utils/installer.sh

    cd $INSTALL_SRC_PATH/
    download "http://www.memcached.org/files/memcached-1.4.17.tar.gz"
    tar xzf memcached-1.4.17.tar.gz
    cd memcached-1.4.17/
    ./configure --prefix=$MOD_MEMCACHED_INSTALL_PATH
    make && make install

    useradd -M -s /sbin/nologin memcached

    if [ -d "$MOD_MEMCACHED_INSTALL_PATH" ];then
        ln -s $MOD_MEMCACHED_INSTALL_PATH/bin/memcached /usr/bin/memcached
        /bin/cp $IN_PWD/module/$MOD_MEMCACHED/$MOD_MEMCACHED_VER/conf/Memcached-init /etc/init.d/memcached
        sed -i "s@/usr/local/memcached@$MOD_MEMCACHED_INSTALL_PATH@g" /etc/init.d/memcached

        echo -e "\033[32mmemcached install successfully! \033[0m"
        chkconfig --add memcached
        chkconfig memcached on
        service memcached start
    else
        echo -e "\033[31mmemcached install failed, Please contact the author! \033[0m"
    fi

    # ============================

    printf "

Memcached Install Information
=============================

Memcached Version: $MOD_MEMCACHED_VER

Memcached Install Path: $MOD_MEMCACHED_INSTALL_PATH

Usage: service memcached {start|stop|force-quit|restart|reload|status}

Created: `date`

-------------------------


    " >> $INSTALL_PATH/install.info

    # ============================
}
