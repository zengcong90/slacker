#!/bin/bash
# Author:  Allen <movoin@gmail.com>
# Website:  http://movoin.com
#
# MySQL Module
#

Install_MySQL()
{
printf "

#######################################################################
                         INSTALL MYSQL 5.6
#######################################################################

"

if [ ! -e "`which cmake`" ];then
    yum -y install cmake bison-devel
fi

. $IN_PWD/func/downloader.sh
cd $IN_PWD/src/
Download_To_Src "http://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.15.tar.gz"
tar zxf mysql-5.6.15.tar.gz
cd mysql-5.6.15/
make clean

# Definition Directory
mkdir -p $INSTALL_PATH/bin/mysql \
    $INSTALL_PATH/data/mysql \
    $INSTALL_PATH/logs/mysql

cmake . -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH/bin/mysql \
    -DMYSQL_DATADIR=$INSTALL_PATH/data/mysql \
    -DSYSCONFDIR=/etc \
    -DWITH_INNOBASE_STORAGE_ENGINE=1 \
    -DWITH_PARTITION_STORAGE_ENGINE=1 \
    -DWITH_FEDERATED_STORAGE_ENGINE=1 \
    -DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
    -DWITH_MYISAM_STORAGE_ENGINE=1 \
    -DWITH_READLINE=1 \
    -DMYSQL_UNIX_ADDR=$INSTALL_PATH/bin/mysql/mysql.sock \
    -DMYSQL_TCP_PORT=3306 \
    -DENABLED_LOCAL_INFILE=1 \
    -DEXTRA_CHARSETS=all \
    -DDEFAULT_CHARSET=utf8 \
    -DMYSQL_USER=mysql \
    -DWITH_EMBEDDED_SERVER=1 \
    -DDEFAULT_COLLATION=utf8_general_ci
make && make install

if [ -d "$INSTALL_PATH/bin/mysql/bin" ];then
    echo -e "\033[32mMySQL install successfully! \033[0m"
else
    echo -e "\033[31mMySQL install failed, Please contact the author! \033[0m"
    kill -9 $$
fi

ln -s /opt/lnmp/bin/mysql/lib/libmysqlclient.18.1.0 /usr/lib/libmysqlclient.18.1.0

useradd -M -s /sbin/nologin mysql
chown -R mysql:mysql $INSTALL_PATH/bin/mysql $INSTALL_PATH/data/mysql $INSTALL_PATH/logs/mysql

/bin/cp support-files/mysql.server /etc/init.d/mysql
chmod +x /etc/init.d/mysql

. $IN_PWD/func/check_os.sh
OSCMD='chkconfig --add mysql \n
chkconfig mysql on'
OS_command
cd $IN_PWD

# Backup my.cnf
mv /etc/my.cnf $INSTALL_PATH/backup/my.cnf

# my.cf
cat > /etc/my.cnf << EOF
[client]
port = 3306
socket = $INSTALL_PATH/bin/mysql/mysql.sock

[mysqld]
port = 3306
socket = $INSTALL_PATH/bin/mysql/mysql.sock

basedir = $INSTALL_PATH/bin/mysql
datadir = $INSTALL_PATH/data/mysql
pid-file = $INSTALL_PATH/data/mysql/mysql.pid
user = mysql
bind-address = 0.0.0.0
server-id = 1

skip-name-resolve
#skip-networking
back_log = 600

log_error = $INSTALL_PATH/logs/mysql/error.log
slow_query_log = 1
long_query_time = 1
slow_query_log_file = $INSTALL_PATH/logs/mysql/slow.log

performance_schema = 0
explicit_defaults_for_timestamp

#lower_case_table_names = 1

skip-external-locking

default_storage_engine = InnoDB
#default-storage-engine = MyISAM
innodb_file_per_table = 1
innodb_open_files = 500
innodb_buffer_pool_size = 64M
innodb_write_io_threads = 4
innodb_read_io_threads = 4
innodb_thread_concurrency = 0
innodb_purge_threads = 1
innodb_flush_log_at_trx_commit = 2
innodb_log_buffer_size = 2M
innodb_log_file_size = 32M
innodb_log_files_in_group = 3
innodb_max_dirty_pages_pct = 90
innodb_lock_wait_timeout = 120

bulk_insert_buffer_size = 8M
myisam_sort_buffer_size = 8M
myisam_max_sort_file_size = 10G
myisam_repair_threads = 1

interactive_timeout = 28800
wait_timeout = 28800

[mysqldump]
quick
max_allowed_packet = 8M

[myisamchk]
key_buffer_size = 8M
sort_buffer_size = 8M
read_buffer = 4M
write_buffer = 4M
EOF

Memtotal=`free -m | grep 'Mem:' | awk '{print $2}'`
if [ $Memtotal -gt 1500 -a $Memtotal -le 2500 ];then
    sed -i 's@^thread_cache_size.*@thread_cache_size = 16@' /etc/my.cnf
    sed -i 's@^query_cache_size.*@query_cache_size = 16M@' /etc/my.cnf
    sed -i 's@^myisam_sort_buffer_size.*@myisam_sort_buffer_size = 16M@' /etc/my.cnf
    sed -i 's@^key_buffer_size.*@key_buffer_size = 16M@' /etc/my.cnf
    sed -i 's@^innodb_buffer_pool_size.*@innodb_buffer_pool_size = 128M@' /etc/my.cnf
    sed -i 's@^tmp_table_size.*@tmp_table_size = 32M@' /etc/my.cnf
    sed -i 's@^table_open_cache.*@table_open_cache = 256@' /etc/my.cnf
elif [ $Memtotal -gt 2500 -a $Memtotal -le 3500 ];then
    sed -i 's@^thread_cache_size.*@thread_cache_size = 32@' /etc/my.cnf
    sed -i 's@^query_cache_size.*@query_cache_size = 32M@' /etc/my.cnf
    sed -i 's@^myisam_sort_buffer_size.*@myisam_sort_buffer_size = 32M@' /etc/my.cnf
    sed -i 's@^key_buffer_size.*@key_buffer_size = 64M@' /etc/my.cnf
    sed -i 's@^innodb_buffer_pool_size.*@innodb_buffer_pool_size = 512M@' /etc/my.cnf
    sed -i 's@^tmp_table_size.*@tmp_table_size = 64M@' /etc/my.cnf
    sed -i 's@^table_open_cache.*@table_open_cache = 512@' /etc/my.cnf
elif [ $Memtotal -gt 3500 ];then
    sed -i 's@^thread_cache_size.*@thread_cache_size = 64@' /etc/my.cnf
    sed -i 's@^query_cache_size.*@query_cache_size = 64M@' /etc/my.cnf
    sed -i 's@^myisam_sort_buffer_size.*@myisam_sort_buffer_size = 64M@' /etc/my.cnf
    sed -i 's@^key_buffer_size.*@key_buffer_size = 256M@' /etc/my.cnf
    sed -i 's@^innodb_buffer_pool_size.*@innodb_buffer_pool_size = 1024M@' /etc/my.cnf
    sed -i 's@^tmp_table_size.*@tmp_table_size = 128M@' /etc/my.cnf
    sed -i 's@^table_open_cache.*@table_open_cache = 1024@' /etc/my.cnf
fi

$INSTALL_PATH/bin/mysql/scripts/mysql_install_db --user=mysql --basedir=$INSTALL_PATH/bin/mysql --datadir=$INSTALL_PATH/data/mysql
chown mysql.mysql -R $INSTALL_PATH/data/mysql
service mysql start

echo "export PATH=\$PATH:$INSTALL_PATH/bin/mysql/bin" >> /etc/profile
. /etc/profile

$INSTALL_PATH/bin/mysql/bin/mysql -e "grant all privileges on *.* to root@'127.0.0.1' identified by \"$MYSQL_ROOT_PW\" with grant option;"
$INSTALL_PATH/bin/mysql/bin/mysql -e "grant all privileges on *.* to root@'localhost' identified by \"$MYSQL_ROOT_PW\" with grant option;"
$INSTALL_PATH/bin/mysql/bin/mysql -uroot -p$MYSQL_ROOT_PW -e "delete from mysql.user where Password='';"
$INSTALL_PATH/bin/mysql/bin/mysql -uroot -p$MYSQL_ROOT_PW -e "delete from mysql.db where User='';"
$INSTALL_PATH/bin/mysql/bin/mysql -uroot -p$MYSQL_ROOT_PW -e "delete from mysql.proxies_priv where Host!='localhost';"
$INSTALL_PATH/bin/mysql/bin/mysql -uroot -p$MYSQL_ROOT_PW -e "drop database test;"
$INSTALL_PATH/bin/mysql/bin/mysql -uroot -p$MYSQL_ROOT_PW -e "reset master;"
service mysql stop

echo -e "\033[32mMySQL ROOT Password : $MYSQL_ROOT_PW \033[0m"

printf "

#######################################################################
                    INSTALL MYSQL 5.6 IS COMPLETE!
#######################################################################

"
}
