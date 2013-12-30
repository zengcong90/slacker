#!/bin/bash
# Author:  Allen <movoin@gmail.com>
# Website:  http://movoin.com
#
# PHP Module
#

Install_MemcachedService()
{
echo "Install Memcached Service..."

. $IN_PWD/options.conf
. $IN_PWD/func/downloader.sh
cd $IN_PWD/src/
Download_To_Src "http://www.memcached.org/files/memcached-1.4.17.tar.gz"
tar xzf memcached-1.4.17.tar.gz
cd memcached-1.4.17/
./configgure --prefix=$INSTALL_PATH/bin/memcached
make && make install

if [ -d "$INSTALL_PATH/bin/memcached" ];then
    useradd -M -s /sbin/nologin memcached
    ln -s $INSTALL_PATH/bin/memcached/bin/memcached /usr/bin/memcached
    /bin/cp $IN_PWD/conf/Memcached-init /etc/init.d/memcached
    chkconfig --add memcached
    chkconfig memcached on
    sed -i "s@/usr/local/memcached@$INSTALL_PATH/bin/memcached@g" /etc/init.d/memcached
    service memcached start
    echo -e "\033[32mmemcached install successfully! \033[0m"
else
    echo -e "\033[31mmemcached install failed, Please contact the author! \033[0m"
fi

echo "Install Memcached Service Is Complete!..."
}


Install_MemcachedExtends()
{
. $IN_PWD/options.conf
. $IN_PWD/func/downloader.sh

echo "Install LibMemcached..."

cd $IN_PWD/src/
Download_To_Src "https://launchpad.net/libmemcached/1.0/1.0.17/+download/libmemcached-1.0.17.tar.gz"
tar xzf libmemcached-1.0.17.tar.gz
cd libmemcached-1.0.17/
./configure --with-memcached=$INSTALL_PATH/bin/memcached
make && make install

echo "Install LibMemcached Is Complete!..."


echo "Install Memcached PHP Extension..."

cd $IN_PWD/src/
Download_To_Src "http://pecl.php.net/get/memcached-2.1.0.tgz"
tar xzf memcached-2.1.0.tgz
cd memcached-2.1.0/
make clean
$INSTALL_PATH/bin/php/bin/phpize
./configure --with-php-config=$INSTALL_PATH/bin/php/bin/php-config
make && make install

if [ -f "$INSTALL_PATH/bin/php/lib/php/extensions/`ls $INSTALL_PATH/bin/php/lib/php/extensions`/memcached.so" ];then
    [ -z "`cat $INSTALL_PATH/bin/php/etc/php.ini | grep '^extension_dir'`" ] && sed -i "s@extension_dir = \"ext\"@extension_dir = \"ext\"\nextension_dir = \"$INSTALL_PATH/bin/php/lib/php/extensions/`ls $INSTALL_PATH/bin/php/lib/php/extensions/`\"@" $INSTALL_PATH/bin/php/etc/php.ini
        sed -i 's@^extension_dir\(.*\)@extension_dir\1\nextension = "memcached.so"@' $INSTALL_PATH/bin/php/etc/php.ini
else
        echo -e "\033[31mPHP memcached module install failed, Please contact the author! \033[0m"
fi

echo "Install Memcached PHP Extension Is Complete!..."
}

