#!/bin/bash
#
# Module: Nginx
# Version: 1.5.8
#
# Author:  Allen <movoin@gmail.com>
# Website:  http://movoin.com
#

install_nginx()
{
    . $IN_PWD/GLOBAL.conf
    . $IN_PWD/utils/helper.sh
    . $IN_PWD/utils/installer.sh

    cd $INSTALL_SRC_PATH/
    download "http://downloads.sourceforge.net/project/pcre/pcre/8.33/pcre-8.33.tar.gz" \
        "http://nginx.org/download/nginx-1.5.8.tar.gz"

    tar xzf pcre-8.33.tar.gz
    cd pcre-8.33
    ./configure
    make && make install
    cd ../

    useradd -M -s /sbin/nologin www

    tar xzf nginx-1.5.8.tar.gz
    cd nginx-1.5.8/

    sed -i 's@CFLAGS="$CFLAGS -g"@#CFLAGS="$CFLAGS -g"@' auto/cc/gcc

    ./configure \
        --prefix=$MOD_WEB_INSTALL_PATH \
        --user=www \
        --group=www \
        --with-http_stub_status_module \
        --with-http_ssl_module \
        --with-http_flv_module \
        --with-http_gzip_static_module
    make && make install

    if [ -d "$MOD_WEB_INSTALL_PATH" ];then
        echo -e "\033[32mNginx install successfully! \033[0m"
    else
        echo -e "\033[31mNginx install failed, Please Contact the author! \033[0m"
        kill -9 $$
    fi

    cd $INSTALL_PATH/

    mkdir -p $INSTALL_WWW_PATH/default $MOD_WEB_LOG_PATH

    /bin/cp $IN_PWD/module/$MOD_WEB/$MOD_WEB_VER/conf/Nginx-init /etc/init.d/nginx
    sed -i "s@/usr/local/nginx@$MOD_WEB_INSTALL_PATH@g" /etc/init.d/nginx
    chmod +x /etc/init.d/nginx
    chkconfig --add nginx
    chkconfig nginx on

    /bin/mv $MOD_WEB_INSTALL_PATH/conf/nginx.conf $INSTALL_BACKUP_PATH/nginx.conf
    /bin/cp $IN_PWD/module/$MOD_WEB/$MOD_WEB_VER/conf/nginx.conf $MOD_WEB_INSTALL_PATH/conf/nginx.conf
    sed -i "s@/home/wwwroot/default@$INSTALL_WWW_PATH/default@" $MOD_WEB_INSTALL_PATH/conf/nginx.conf
    sed -i "s@/home/wwwlogs@$MOD_WEB_LOG_PATH@g" $MOD_WEB_INSTALL_PATH/conf/nginx.conf

    cat > /etc/logrotate.d/nginx << EOF
    $MOD_WEB_LOG_PATH/*nginx.log {
daily
rotate 5
missingok
dateext
compress
notifempty
sharedscripts
postrotate
    [ -e /var/run/nginx.pid ] && kill -USR1 \`cat /var/run/nginx.pid\`
endscript
}
    EOF

    ldconfig
    service nginx start
}
