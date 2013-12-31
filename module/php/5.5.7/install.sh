#!/bin/bash
#
# Module: PHP
# Version: 5.5.7
#
# Author:  Allen <movoin@gmail.com>
# Website:  http://movoin.com
#

install_php()
{
    # PHP Needs
    install_php_needs

    . $IN_PWD/GLOBAL.conf
    . $IN_PWD/utils/helper.sh
    . $IN_PWD/utils/installer.sh

    cd $INSTALL_SRC_PATH/
    download "http://www.php.net/get/php-5.5.7.tar.gz/from/this/mirror"
    tar xzf php-5.5.7.tar.gz

    useradd -M -s /sbin/nologin www
    mkdir -p $MOD_PHP_LOG_PATH

    if [ $MOD_PHP_MODE == 'fpm' ];then
        # FPM Race Condition Patch
        wget -O fpm-race-condition.patch 'https://bugs.php.net/patch-display.php?bug_id=65398&patch=fpm-race-condition.patch&revision=1375772074&download=1'
        patch -d php-5.5.7 -p0 < fpm-race-condition.patch
    fi

    cd php-5.5.7
    make clean

    WITH_MYSQL=''
    if [ ! $MOD_DB == '' ];then
        WITH_MYSQL=<<<EOF
        --with-mysql=$MOD_DB_INSTALL_PATH \
        --with-mysqli=$MOD_DB_INSTALL_PATH/bin/mysql_config \
        --with-pdo-mysql=$MOD_DB_INSTALL_PATH/bin/mysql_config \
        EOF
    fi

    if [ $EXT_OPCACHE_INSTALL == 'y' ];then
        $ENB_OPCACHE='--enable-opcache'
    fi

    if [ $MOD_WEB == 'apache' ]; then
        CFLAGS= CXXFLAGS= ./configure \
            --prefix=$MOD_PHP_INSTALL_PATH \
            --with-config-file-path=$MOD_PHP_INSTALL_PATH/etc \
            --with-apxs2=$MOD_WEB_INSTALL_PATH/bin/apxs \
            --with-iconv-dir=/usr/local \
            --with-freetype-dir \
            --with-jpeg-dir \
            --with-png-dir \
            --with-zlib \
            --with-libxml-dir=/usr \
            --with-curl \
            --with-kerberos \
            --with-mcrypt \
            --with-gd \
            --with-xsl \
            --with-openssl \
            --with-mhash \
            --with-ldap \
            --with-ldap-sasl \
            --with-xmlrpc \
            --with-gettext \
            --enable-xml \
            --enable-bcmath \
            --enable-shmop \
            --enable-exif \
            --enable-sysvsem \
            --enable-inline-optimization \
            --enable-mbregex \
            --enable-mbstring \
            --enable-gd-native-ttf \
            --enable-pcntl \
            --enable-sockets \
            --enable-ftp \
            --enable-zip \
            --enable-soap \
            --enable-maintainer-zts \
            --disable-fileinfo \
            --disable-rpath \
            --disable-ipv6 \
            --disable-debug \
            $WITH_MYSQL
            $ENB_OPCACHE

    else
        CFLAGS= CXXFLAGS= ./configure \
            --prefix=$MOD_PHP_INSTALL_PATH \
            --with-config-file-path=$MOD_PHP_INSTALL_PATH/etc \
            --with-fpm-user=www \
            --with-fpm-group=www \
            --with-iconv-dir=/usr/local \
            --with-freetype-dir \
            --with-jpeg-dir \
            --with-png-dir \
            --with-zlib \
            --with-libxml-dir=/usr \
            --with-curl \
            --with-kerberos \
            --with-mcrypt \
            --with-gd \
            --with-xsl \
            --with-openssl \
            --with-mhash \
            --with-ldap \
            --with-ldap-sasl \
            --with-xmlrpc \
            --with-gettext \
            --enable-fpm \
            --enable-xml \
            --enable-bcmath \
            --enable-shmop \
            --enable-exif \
            --enable-sysvsem \
            --enable-inline-optimization \
            --enable-mbregex \
            --enable-mbstring \
            --enable-gd-native-ttf \
            --enable-pcntl \
            --enable-sockets \
            --enable-zip \
            --enable-soap \
            --enable-maintainer-zts \
            --disable-fileinfo \
            --disable-rpath \
            --disable-ipv6 \
            --disable-debug \
            $WITH_MYSQL
            $ENB_OPCACHE

    fi

    make ZEND_EXTRA_LIBS='-liconv'
    make install

    if [ -d "$MOD_PHP_INSTALL_PATH" ];then
        echo -e "\033[32mPHP install successfully! \033[0m"
    else
        echo -e "\033[31mPHP install failed, Please Contact the author! \033[0m"
        kill -9 $$
    fi

    /bin/cp php.ini-development $MOD_PHP_INSTALL_PATH/etc/php.ini
    sed -i "s@^;short_open_tag = Off@short_open_tag = On@" $MOD_PHP_INSTALL_PATH/etc/php.ini
    sed -i "s@^;date.timezone =@date.timezone = 'Asia/Shanghai'@" $MOD_PHP_INSTALL_PATH/etc/php.ini
    sed -i "s@^;error_log = syslog@error_log = $MOD_PHP_LOG_PATH/error.log@" $MOD_PHP_INSTALL_PATH/etc/php.ini
    [ -e /usr/sbin/sendmail ] && sed -i "s@^;sendmail_path.*@sendmail_path = /usr/sbin/sendmail -t -i@" $MOD_PHP_INSTALL_PATH/etc/php.ini

    # Enable OPCache Extension
    if [ $EXT_OPCACHE_INSTALL == 'y' ] && [ $EXT_OPCACHE_ENABLE == 'y' ];then
        sed -i 's@^\[opcache\]@[opcache]\nzend_extension=opcache.so@' $MOD_PHP_INSTALL_PATH/etc/php.ini
        sed -i 's@^;opcache.enable=.*@opcache.enable=1@' $MOD_PHP_INSTALL_PATH/etc/php.ini
        sed -i 's@^;opcache.memory_consumption.*@opcache.memory_consumption=64@' $MOD_PHP_INSTALL_PATH/etc/php.ini
        sed -i 's@^;opcache.interned_strings_buffer.*@opcache.interned_strings_buffer=8@' $MOD_PHP_INSTALL_PATH/etc/php.ini
        sed -i 's@^;opcache.max_accelerated_files.*@opcache.max_accelerated_files=4000@' $MOD_PHP_INSTALL_PATH/etc/php.ini
        sed -i 's@^;opcache.revalidate_freq.*@opcache.revalidate_freq=60@' $MOD_PHP_INSTALL_PATH/etc/php.ini
        sed -i 's@^;opcache.save_comments.*@opcache.save_comments=0@' $MOD_PHP_INSTALL_PATH/etc/php.ini
        sed -i 's@^;opcache.fast_shutdown.*@opcache.fast_shutdown=1@' $MOD_PHP_INSTALL_PATH/etc/php.ini
        sed -i 's@^;opcache.enable_cli.*@opcache.enable_cli=1@' $MOD_PHP_INSTALL_PATH/etc/php.ini
    fi

    echo "export PATH=\$PATH:$MOD_PHP_INSTALL_PATH/bin" >> /etc/profile
    . /etc/profile

    if [ $MOD_PHP_MODE == 'fpm' ] || [ ! $MOD_WEB == 'apache' ];then
        /bin/cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
        chmod +x /etc/init.d/php-fpm

        chkconfig --add php-fpm
        chkconfig php-fpm on

        /bin/cp $MOD_PHP_INSTALL_PATH/etc/php-fpm.conf.default $MOD_PHP_INSTALL_PATH/etc/php-fpm.conf
        sed -i "s@^;access.log.*@access.log = $MOD_PHP_LOG_PATH/fpm-access.log@" $MOD_PHP_INSTALL_PATH/etc/php-fpm.conf
        sed -i "s@^;error_log.*@error_log = $MOD_PHP_LOG_PATH/fpm-error.log@" $MOD_PHP_INSTALL_PATH/etc/php-fpm.conf
        sed -i "s@^;slowlog.*@slowlog = $MOD_PHP_LOG_PATH/fpm-slow.log@" $MOD_PHP_INSTALL_PATH/etc/php-fpm.conf
        #sed -i "s@^listen =.*@listen = $MYIPADDR:9000@" $MOD_PHP_INSTALL_PATH/etc/php-fpm.conf
        sed -i "s@^listen =.*@listen = /dev/shm/php-cgi.sock@" $MOD_PHP_INSTALL_PATH/etc/php-fpm.conf
        sed -i "s@^;catch_workers_output = yes@catch_workers_output = yes@" $MOD_PHP_INSTALL_PATH/etc/php-fpm.conf
        sed -i "s@^;env[HOSTNAME] = \$HOSTNAME@env[HOSTNAME] = \$HOSTNAME@" $MOD_PHP_INSTALL_PATH/etc/php-fpm.conf
        sed -i "s@^;env[PATH] = /usr/local/bin:/usr/bin:/bin@env[PATH] = /usr/local/bin:/usr/bin:/bin@" $MOD_PHP_INSTALL_PATH/etc/php-fpm.conf
        sed -i "s@^;env[TMP] = /tmp@env[TMP] = /tmp@" $MOD_PHP_INSTALL_PATH/etc/php-fpm.conf
        sed -i "s@^;env[TMPDIR] = /tmp@env[TMPDIR] = /tmp@" $MOD_PHP_INSTALL_PATH/etc/php-fpm.conf
        sed -i "s@^;env[TEMP] = /tmp@env[TEMP] = /tmp@" $MOD_PHP_INSTALL_PATH/etc/php-fpm.conf
        service php-fpm start
    fi

    if [ $MOD_WEB == 'apache' ];then
        sed -i 's@^#LoadModule\(.*\)php5_module.so@LoadModule\1php5_module.so@' $MOD_WEB_INSTALL_PATH/conf/httpd.conf
        sed -i 's@^#LoadModule\(.*\)mod_deflate.so@LoadModule\1mod_deflate.so@' $MOD_WEB_INSTALL_PATH/conf/httpd.conf
        sed -i "s@AddType\(.*\)Z@AddType\1Z\n    AddType application/x-httpd-php .php .phtml\n    AddType application/x-httpd-php-source .phps@" $MOD_WEB_INSTALL_PATH/conf/httpd.conf
        sed -i 's@DirectoryIndex index.html@DirectoryIndex index.html index.htm index.php@' $MOD_WEB_INSTALL_PATH/conf/httpd.conf
        sed -i "s@^#Include conf/extra/httpd-mpm.conf@Include conf/extra/httpd-mpm.conf@" $MOD_WEB_INSTALL_PATH/conf/httpd.conf

        service httpd restart
    fi

    # ============================

    printf "

PHP Install Information
=========================

PHP Version: $MOD_PHP_VER
PHP Mode: $MOD_PHP_MODE

PHP Install Path: $MOD_PHP_INSTALL_PATH
PHP Log Path: $MOD_PHP_LOG_PATH

Usage: service php-fpm {start|stop|force-quit|restart|reload|status}

Created: `date`

-------------------------


    " >> $INSTALL_PATH/install.info

    # ============================
}

# PHP Needs
install_php_needs()
{
    . $IN_PWD/GLOBAL.conf
    . $IN_PWD/utils/helper.sh
    . $IN_PWD/utils/installer.sh

    cd $INSTALL_SRC_PATH/
    download "http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz" \
        "http://downloads.sourceforge.net/project/mcrypt/Libmcrypt/2.5.8/libmcrypt-2.5.8.tar.gz" \
        "http://downloads.sourceforge.net/project/mhash/mhash/0.9.9.9/mhash-0.9.9.9.tar.gz" \
        "http://downloads.sourceforge.net/project/mcrypt/MCrypt/2.6.8/mcrypt-2.6.8.tar.gz"

    tar xzf libiconv-1.14.tar.gz
    cd libiconv-1.14
    make clean
    ./configure --prefix=/usr/local
    make && make install
    cd ../

    tar xzf libmcrypt-2.5.8.tar.gz
    cd libmcrypt-2.5.8
    make clean
    ./configure
    make && make install
    ldconfig
    cd libltdl/
    ./configure --enable-ltdl-install
    make && make install
    cd ../../

    tar xzf mhash-0.9.9.9.tar.gz
    cd mhash-0.9.9.9
    make clean
    ./configure
    make && make install
    cd ../

    # ln libraries
    if [ ! $MOD_DB == '' ];then
        ln -s $MOD_DB_INSTALL_PATH/include /usr/include/mysql
        echo "$MOD_DB_INSTALL_PATH/lib" > /etc/ld.so.conf.d/mysql.conf
    fi

    echo "/usr/local/lib" > /etc/ld.so.conf.d/local.conf
    ldconfig

    ln -s /usr/local/bin/libmcrypt-config /usr/bin/libmcrypt-config
    if [ `getconf WORD_BIT` == 32 ] && [ `getconf LONG_BIT` == 64 ];then
        ln -s /lib64/libpcre.so.0.0.1 /lib64/libpcre.so.1
        ln -s /usr/lib64/libldap* /usr/lib
    else
        ln -s /lib/libpcre.so.0.0.1 /lib/libpcre.so.1
    fi

    tar xzf mcrypt-2.6.8.tar.gz
    cd mcrypt-2.6.8
    make clean
    ldconfig
    ./configure
    make && make install
}
