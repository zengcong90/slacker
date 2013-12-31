#!/bin/bash
#
# Module: MySQL
# Version: 5.6.15
#
# Author:  Allen <movoin@gmail.com>
# Website:  http://movoin.com
#

install_mysql()
{
    . $IN_PWD/GLOBAL.conf
    . $IN_PWD/utils/helper.sh
    . $IN_PWD/utils/installer.sh

    yum -y install bison-devel

    if [ ! -e "`which cmake`" ];then
        yum -y install cmake
    fi

    cd $INSTALL_SRC_PATH/
    download "http://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.15.tar.gz"
    tar zxf mysql-5.6.15.tar.gz
    cd mysql-5.6.15/
    make clean

    # Definition Directory
    mkdir -p $MOD_DB_DATA_PATH $MOD_DB_LOG_PATH

    cmake . -DCMAKE_INSTALL_PREFIX=$MOD_DB_INSTALL_PATH \
        -DMYSQL_DATADIR=$MOD_DB_DATA_PATH \
        -DSYSCONFDIR=/etc \
        -DWITH_INNOBASE_STORAGE_ENGINE=1 \
        -DWITH_PARTITION_STORAGE_ENGINE=1 \
        -DWITH_FEDERATED_STORAGE_ENGINE=1 \
        -DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
        -DWITH_MYISAM_STORAGE_ENGINE=1 \
        -DWITH_READLINE=1 \
        -DMYSQL_UNIX_ADDR=$MOD_DB_INSTALL_PATH/mysql.sock \
        -DMYSQL_TCP_PORT=3306 \
        -DENABLED_LOCAL_INFILE=1 \
        -DEXTRA_CHARSETS=all \
        -DDEFAULT_CHARSET=utf8 \
        -DMYSQL_USER=mysql \
        -DWITH_EMBEDDED_SERVER=1 \
        -DDEFAULT_COLLATION=utf8_general_ci
    make && make install

    if [ -d "$MOD_DB_INSTALL_PATH" ];then
        echo -e "\033[32mMySQL install successfully! \033[0m"
    else
        echo -e "\033[31mMySQL install failed, Please contact the author! \033[0m"
        kill -9 $$
    fi

    # MySQL CLient Library
    ln -s $MOD_DB_INSTALL_PATH/lib/libmysqlclient.18.1.0 /usr/lib/libmysqlclient.18.1.0

    # Create User
    useradd -M -s /sbin/nologin mysql
    chown -R mysql:mysql $MOD_DB_INSTALL_PATH $MOD_DB_DATA_PATH $MOD_DB_LOG_PATH

    # Add Service
    /bin/cp support-files/mysql.server /etc/init.d/mysql
    chmod +x /etc/init.d/mysql
    chkconfig --add mysql
    chkconfig mysql on

    # Backup my.cnf
    mv /etc/my.cnf $INSTALL_BACKUP_PATH/my.cnf

    # my.cnf
    cp $IN_PWD/module/$MOD_DB/$MOD_DB_VER/conf/my.cnf /etc/my.cnf

    sed -i "s@^socket = mysql.sock@socket = $MOD_DB_INSTALL_PATH/mysql.sock@" /etc/my.cnf
    sed -i "s@^basedir =@basedir = $MOD_DB_INSTALL_PATH@" /etc/my.cnf
    sed -i "s@^datadir =@datadir = $MOD_DB_DATA_PATH@" /etc/my.cnf
    sed -i "s@^pid-file = mysql.pid@pid-file = $MOD_DB_DATA_PATH/mysql.pid@" /etc/my.cnf
    sed -i "s@^log_error = error.log@pid-file = $MOD_DB_LOG_PATH/error.log@" /etc/my.cnf
    sed -i "s@^slow_query_log_file = slow.log@slow_query_log_file = $MOD_DB_LOG_PATH/slow.log@" /etc/my.cnf

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

    # Install DB
    $MOD_DB_INSTALL_PATH/scripts/mysql_install_db --user=mysql --basedir=$MOD_DB_INSTALL_PATH --datadir=$MOD_DB_DATA_PATH
    service mysql start

    echo "export PATH=\$PATH:$MOD_DB_INSTALL_PATH/bin" >> /etc/profile
    . /etc/profile

    mysql -e "grant all privileges on *.* to root@'127.0.0.1' identified by \"$MOD_DB_ROOT_PW\" with grant option;"
    mysql -e "grant all privileges on *.* to root@'localhost' identified by \"$MOD_DB_ROOT_PW\" with grant option;"
    mysql -uroot -p$MOD_DB_ROOT_PW -e "delete from mysql.user where Password='';"
    mysql -uroot -p$MOD_DB_ROOT_PW -e "delete from mysql.db where User='';"
    mysql -uroot -p$MOD_DB_ROOT_PW -e "delete from mysql.proxies_priv where Host!='localhost';"
    mysql -uroot -p$MOD_DB_ROOT_PW -e "drop database test;"
    mysql -uroot -p$MOD_DB_ROOT_PW -e "reset master;"

    service mysql stop

    # ============================

    printf "

MySQL Install Information
=========================

MySQL Version: $MOD_DB_VER
MySQL User: root
MySQL Password: $MOD_DB_ROOT_PW

MySQL Install Path: $MOD_DB_INSTALL_PATH
MySQL Data Path: $MOD_DB_DATA_PATH
MySQL Log Path: $MOD_DB_LOG_PATH

Usage: service mysql {start|stop|restart|reload|force-reload|status}

Created: `date`

-------------------------


    " >> $INSTALL_PATH/install.info

    # ============================
}
