#!/bin/bash
#
# PHP Extension: imagick
# Version: 3.1.2
# ImageMagick Version: 6.8.8-0
#
# Author:  Allen <movoin@gmail.com>
# Website:  http://movoin.com
#

install_ext_imagick()
{
    . $IN_PWD/GLOBAL.conf
    . $IN_PWD/utils/helper.sh
    . $IN_PWD/utils/installer.sh

    cd $INSTALL_SRC_PATH/
    download "http://sourceforge.net/projects/imagemagick/files/6.8.8-sources/ImageMagick-6.8.8-0.tar.gz/download" \
        "http://pecl.php.net/get/imagick-3.1.2.tgz"

    tar xzf ImageMagick-6.8.8-0.tar.gz
    cd ImageMagick-6.8.8-0/
    make clean
    ./configure
    make && make install

    ln -s /usr/local/include/ImageMagick-6 /usr/local/include/ImageMagick
    cd ../

    tar xzf imagick-3.1.2.tgz
    cd imagick-3.1.2/
    make clean
    export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
    $MOD_PHP_INSTALL_PATH/bin/phpize
    ./configure --with-php-config=$MOD_PHP_INSTALL_PATH/bin/php-config
    make && make install
    cd ../

    if [ -f "$MOD_PHP_INSTALL_PATH/lib/php/extensions/`ls $MOD_PHP_INSTALL_PATH/lib/php/extensions`/imagick.so" ];then
        if [ $EXT_IMAGICK_ENABLE == 'y' ];then
            sed -i 's@^extension_dir\(.*\)@extension_dir\1\nextension = "imagick.so"@' $MOD_PHP_INSTALL_PATH/etc/php.ini
            if [ $MOD_PHP_MODE == 'fpm' ] || [ ! $MOD_WEB == 'apache' ];then
                service php-fpm restart
            fi
            if [ $MOD_WEB == 'apache' ];then
                service httpd restart
            fi
        fi
    else
        echo -e "\033[31mPHP imagick module install failed, Please contact the author! \033[0m"
    fi

    # ============================

    printf "

PHP Imagick Extension Install Information
=========================================

ImageMagick Version: 6.8.8-0
Extension Version: 3.1.2
Extension Enabled: $EXT_IMAGICK_ENABLE

Created: `date`

-------------------------


" >> $INSTALL_PATH/install.info

    # ============================
}
