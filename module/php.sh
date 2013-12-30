#!/bin/bash
# Author:  Allen <movoin@gmail.com>
# Website:  http://movoin.com
#
# PHP Module
#

Install_PHPNeeds()
{
printf "

#######################################################################
                    INSTALL DEPENDENT LIBRARIES
#######################################################################

"
. $IN_PWD/options.conf
. $IN_PWD/func/downloader.sh

cd $INSTALL_PATH/src/
Download_To_Src "http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz" \
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
ln -s $INSTALL_PATH/bin/mysql/include /usr/include/mysql
echo "$INSTALL_PATH/bin/mysql/lib" > /etc/ld.so.conf.d/mysql.conf
echo "/usr/local/lib" > /etc/ld.so.conf.d/local.conf
ldconfig
OSCMD='ln -s /usr/local/bin/libmcrypt-config /usr/bin/libmcrypt-config \n
if [ `getconf WORD_BIT` == 32 ] && [ `getconf LONG_BIT` == 64 ];then \n
        ln -s /lib64/libpcre.so.0.0.1 /lib64/libpcre.so.1 \n
        ln -s /usr/lib64/libldap* /usr/lib \n
else \n
        ln -s /lib/libpcre.so.0.0.1 /lib/libpcre.so.1 \n
fi'
OS_command

tar xzf mcrypt-2.6.8.tar.gz
cd mcrypt-2.6.8
make clean
ldconfig
./configure
make && make install
cd ../

printf "

#######################################################################
                INSTALL DEPENDENT LIBRARIES IS COMPLETE!
#######################################################################

"
}

Install_PHP()
{
printf "

#######################################################################
                         INSTALL PHP 5.5.7
#######################################################################

"
. $IN_PWD/options.conf
. $IN_PWD/func/downloader.sh

cd $INSTALL_PATH/src/
Download_To_Src "http://www.php.net/get/php-5.5.7.tar.gz/from/this/mirror"
tar xzf php-5.5.7.tar.gz

useradd -M -s /sbin/nologin www
mkdir -p $INSTALL_PATH/logs/php

# FPM Race Condition Patch
wget -O fpm-race-condition.patch 'https://bugs.php.net/patch-display.php?bug_id=65398&patch=fpm-race-condition.patch&revision=1375772074&download=1'
patch -d php-5.5.7 -p0 < fpm-race-condition.patch

cd php-5.5.7
make clean

CFLAGS= CXXFLAGS= ./configure \
    --prefix=$INSTALL_PATH/bin/php \
    --with-config-file-path=$INSTALL_PATH/bin/php/etc \
    --with-fpm-user=www \
    --with-fpm-group=www \
    --with-mysql=$INSTALL_PATH/bin/mysql \
    --with-mysqli=$INSTALL_PATH/bin/mysql/bin/mysql_config \
    --with-pdo-mysql=$INSTALL_PATH/bin/mysql/bin/mysql_config \
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
    --enable-opcache \
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
    --disable-ipv6

make ZEND_EXTRA_LIBS='-liconv'
make install

if [ -d "$INSTALL_PATH/bin/php/bin" ];then
    echo -e "\033[32mPHP install successfully! \033[0m"
else
    echo -e "\033[31mPHP install failed, Please Contact the author! \033[0m"
    kill -9 $$
fi

/bin/cp php.ini-development $INSTALL_PATH/bin/php/etc/php.ini
sed -i "s@^;error_log = syslog@error_log = $INSTALL_PATH/logs/php/error.log@" $INSTALL_PATH/bin/php/etc/php.ini
[ -e /usr/sbin/sendmail ] && sed -i "s@^;sendmail_path.*@sendmail_path = /usr/sbin/sendmail -t -i@" $INSTALL_PATH/bin/php/etc/php.ini

/bin/cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm

chkconfig --add php-fpm
chkconfig php-fpm on

/bin/cp $INSTALL_PATH/bin/php/etc/php-fpm.conf.default $INSTALL_PATH/bin/php/etc/php-fpm.conf
sed -i "s@^;error_log.*@error_log = $INSTALL_PATH/logs/php/fpm-error.log@" $INSTALL_PATH/bin/php/etc/php-fpm.conf
sed -i "s@^;slowlog.*@slowlog = $INSTALL_PATH/logs/php/fpm-slow.log@" $INSTALL_PATH/bin/php/etc/php-fpm.conf
sed -i "s@^;env\[HOSTNAME\].*@env\[HOSTNAME\] = $HOSTNAME@" $INSTALL_PATH/bin/php/etc/php-fpm.conf

service php-fpm start

echo "export PATH=\$PATH:$INSTALL_PATH/bin/php/bin" >> /etc/profile
. /etc/profile

cd $INSTALL_PATH/

php -v
php -i

printf "

#######################################################################
                    INSTALL PHP 5.5.7 IS COMPLETE!
#######################################################################

"
}

Install_PHPExtends()
{
printf "

#######################################################################
                        INSTALL PHP EXTENDS
#######################################################################

"

# Memcached
if [ -s "$IN_PWD/module/memcached.sh" ];then
    . $IN_PWD/module/memcached.sh
    Install_MemcachedService 2>&1 | tee -a $INSTALL_PATH/install.log
    Install_MemcachedExtends 2>&1 | tee -a $INSTALL_PATH/install.log
    /bin/mv $IN_PWD/module/memcached.sh $IN_PWD/module/memcached.ed
fi

# Imagick
if [ -s "$IN_PWD/module/imagick.sh" ];then
    . $IN_PWD/module/memcached.sh
    Install_ImageMagick 2>&1 | tee -a $INSTALL_PATH/install.log
    Install_Imagick 2>&1 | tee -a $INSTALL_PATH/install.log
    /bin/mv $IN_PWD/module/imagick.sh $IN_PWD/module/imagick.ed
fi

# PECL HTTP
if [ -s "$IN_PWD/module/pecl_http.sh" ];then
    . $IN_PWD/module/pecl_http.sh
    Install_Raphf 2>&1 | tee -a $INSTALL_PATH/install.log
    Install_Propro 2>&1 | tee -a $INSTALL_PATH/install.log
    Install_PECLHTTP 2>&1 | tee -a $INSTALL_PATH/install.log
    /bin/mv $IN_PWD/module/pecl_http.sh $IN_PWD/module/pecl_http.ed
fi

# Hidef
if [ -s "$IN_PWD/module/hidef.sh" ];then
    . $IN_PWD/module/hidef.sh
    Install_Hidef 2>&1 | tee -a $INSTALL_PATH/install.log
    /bin/mv $IN_PWD/module/hidef.sh $IN_PWD/module/hidef.ed
fi

# pthreads
if [ -s "$IN_PWD/module/pthreads.sh" ];then
    . $IN_PWD/module/pthreads.sh
    Install_Pthreads 2>&1 | tee -a $INSTALL_PATH/install.log
    /bin/mv $IN_PWD/module/pthreads.sh $IN_PWD/module/pthreads.ed
fi

# XDebug
if [ -s "$IN_PWD/module/xdebug.sh" ];then
    . $IN_PWD/module/xdebug.sh
    Install_XDebug 2>&1 | tee -a $INSTALL_PATH/install.log
    /bin/mv $IN_PWD/module/xdebug.sh $IN_PWD/module/xdebug.ed
fi

# xhprof
if [ -s "$IN_PWD/module/xhprof.sh" ];then
    . $IN_PWD/module/xhprof.sh
    Install_Xhprof 2>&1 | tee -a $INSTALL_PATH/install.log
    /bin/mv $IN_PWD/module/xhprof.sh $IN_PWD/module/xhprof.ed
fi

printf "

#######################################################################
                    INSTALL PHP EXTENDS IS COMPLETE!
#######################################################################

"
}
