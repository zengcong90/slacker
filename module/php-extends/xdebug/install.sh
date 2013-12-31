#!/bin/bash
#
# PHP Extension: xdebug
# Version: 2.2.3
#
# Author:  Allen <movoin@gmail.com>
# Website:  http://movoin.com
#

install_ext_xdebug()
{
    . $IN_PWD/GLOBAL.conf
    . $IN_PWD/utils/helper.sh
    . $IN_PWD/utils/installer.sh

    cd $INSTALL_SRC_PATH/
    download "http://pecl.php.net/get/xdebug-2.2.3.tgz"

    tar xzf xdebug-2.2.3.tgz
    cd xdebug-2.2.3/
    make clean
    $MOD_PHP_INSTALL_PATH/bin/phpize
    ./configure --with-php-config=$MOD_PHP_INSTALL_PATH/bin/php-config --enable-xdebug
    make && make install

    cd ../

    if [ -f "$MOD_PHP_INSTALL_PATH/lib/php/extensions/`ls $MOD_PHP_INSTALL_PATH/lib/php/extensions`/xdebug.so" ];then
        if [ $EXT_XDEBUG_ENABLE == 'y' ];then
            sed -i 's@^extension_dir\(.*\)@extension_dir\1\nzend_extension = "xdebug.so"@' $MOD_PHP_INSTALL_PATH/etc/php.ini
            if [ $MOD_PHP_MODE == 'fpm' ] || [ ! $MOD_WEB == 'apache' ];then
                service php-fpm restart
            fi
            if [ $MOD_WEB == 'apache' ];then
                service httpd restart
            fi
        fi
    else
        echo -e "\033[31mPHP xdebug module install failed, Please contact the author! \033[0m"
    fi

    # ============================

    printf "

PHP XDebug Extension Install Information
========================================

Extension Version: 2.2.3
Extension Enabled: $EXT_XDEBUG_ENABLE

Created: `date`

-------------------------


" >> $INSTALL_PATH/install.info

    # ============================
}
