#!/bin/bash
#
# PHP Extension: Memcached
# Version: 2.1.0
#
# -OR-
#
# PHP Extension: Memcache
# Version: 2.2.7
#
# Author:  Allen <movoin@gmail.com>
# Website:  http://movoin.com
#

install_ext_memcached()
{
    . $IN_PWD/GLOBAL.conf
    . $IN_PWD/utils/helper.sh
    . $IN_PWD/utils/installer.sh

    cd $INSTALL_SRC_PATH/

    # Memcached
    if [ ! $MOD_MEMCACHED == '' ] && [ ! $MOD_MEMCACHED_VER == '' ];then
        download "http://pecl.php.net/get/memcached-2.1.0.tgz" \
            "https://launchpad.net/libmemcached/1.0/1.0.17/+download/libmemcached-1.0.17.tar.gz"

        tar xzf libmemcached-1.0.17.tar.gz
        cd libmemcached-1.0.17/
        make clean
        ./configure --with-memcached=$MOD_MEMCACHED_INSTALL_PATH
        make && make install
        cd ../

        tar xzf memcached-2.1.0.tgz
        cd memcached-2.1.0/
        make clean
        $MOD_PHP_INSTALL_PATH/bin/phpize
        ./configure --with-php-config=$MOD_PHP_INSTALL_PATH/bin/php-config
        make && make install
        cd ../

        if [ -f "$MOD_PHP_INSTALL_PATH/lib/php/extensions/`ls $MOD_PHP_INSTALL_PATH/lib/php/extensions`/memcached.so" ];then
            sed -i 's@^extension_dir\(.*\)@extension_dir\1\nextension = "memcached.so"@' $MOD_PHP_INSTALL_PATH/etc/php.ini
            if [ $MOD_PHP_MODE == 'fpm' ] || [ ! $MOD_WEB == 'apache' ];then
                service php-fpm restart
            fi
            if [ $MOD_WEB == 'apache' ];then
                service httpd restart
            fi
        else
            echo -e "\033[31mPHP memcached module install failed, Please contact the author! \033[0m"
        fi

        # ============================

        printf "

PHP Memcached Extension Install Information
===========================================

Extension Version: 2.1.0
LibMemcached Version: 1.0.17
Extension Enabled: $EXT_MEMCACHED_ENABLE

Created: `date`

-------------------------


" >> $INSTALL_PATH/install.info

        # ============================

    # Memcache
    else
        download "http://pecl.php.net/get/memcache-2.2.7.tgz"
        tar xzf memcache-2.2.7.tgz
        cd memcache-2.2.7/
        make clean
        $MOD_PHP_INSTALL_PATH/bin/phpize
        ./configure --with-php-config=$MOD_PHP_INSTALL_PATH/bin/php-config
        make && make install
        cd ../

        if [ -f "$MOD_PHP_INSTALL_PATH/lib/php/extensions/`ls $MOD_PHP_INSTALL_PATH/lib/php/extensions`/memcache.so" ];then
            sed -i 's@^extension_dir\(.*\)@extension_dir\1\nextension = "memcache.so"@' $MOD_PHP_INSTALL_PATH/etc/php.ini
            if [ $MOD_PHP_MODE == 'fpm' ] || [ ! $MOD_WEB == 'apache' ];then
                service php-fpm restart
            fi
            if [ $MOD_WEB == 'apache' ];then
                service httpd restart
            fi
        else
            echo -e "\033[31mPHP memcache module install failed, Please contact the author! \033[0m"
        fi

        # ============================

        printf "

PHP Memcache Extension Install Information
==========================================

Extension Version: 2.2.7
Extension Enabled: $EXT_MEMCACHED_ENABLE

Created: `date`

-------------------------


" >> $INSTALL_PATH/install.info

        # ============================
    fi

}
