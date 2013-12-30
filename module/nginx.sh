#!/bin/bash
# Author:  Allen <movoin@gmail.com>
# Website:  http://movoin.com
#
# Nginx Module
#

Install_Nginx()
{
printf "

#######################################################################
                            INSTALL NGINX
#######################################################################

"
. $IN_PWD/options.conf
. $IN_PWD/func/downloader.sh

cd $INSTALL_PATH/src/
Download_To_Src "http://downloads.sourceforge.net/project/pcre/pcre/8.33/pcre-8.33.tar.gz" \
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
    --prefix=$INSTALL_PATH/bin/nginx \
    --user=www \
    --group=www \
    --with-http_stub_status_module \
    --with-http_ssl_module \
    --with-http_flv_module \
    --with-http_gzip_static_module
make && make install

if [ -d "$INSTALL_PATH/bin/nginx" ];then
    echo -e "\033[32mNginx install successfully! \033[0m"
else
    echo -e "\033[31mNginx install failed, Please Contact the author! \033[0m"
    kill -9 $$
fi

cd $INSTALL_PATH/

mkdir -p $INSTALL_PATH/www/default $INSTALL_PATH/logs/nginx

/bin/cp $IN_PWD/conf/Nginx-init /etc/init.d/nginx
chmod +x /etc/init.d/nginx
chkconfig --add nginx
chkconfig nginx on
sed -i "s@/usr/local/nginx@$INSTALL_PATH/bin/nginx@g" /etc/init.d/nginx

mv $INSTALL_PATH/bin/nginx/conf/nginx.conf $INSTALL_PATH/backup/nginx.conf
sed -i "s@/home/wwwroot/default@$INSTALL_PATH/www/default@" $IN_PWD/conf/nginx.conf
/bin/cp $IN_PWD/conf/nginx.conf $INSTALL_PATH/bin/nginx/conf/nginx.conf
sed -i "s@/home/wwwlogs@$INSTALL_PATH/logs/nginx@g" $INSTALL_PATH/bin/nginx/conf/nginx.conf

cat > /etc/logrotate.d/nginx << EOF
$INSTALL_PATH/logs/nginx/*nginx.log {
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

printf "

#######################################################################
                        INSTALL NGINX IS COMPLETE!
#######################################################################

"
}
