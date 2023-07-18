#!/bin/bash
#
# Module: MYSQL
# Version: 5.6.39
#
# Author:  zengcong
# Website:  http://zsxhkj.com
#

install_mysql()
{
    . $IN_PWD/GLOBAL.conf
    . $IN_PWD/utils/helper.sh
    . $IN_PWD/utils/installer.sh 
    yum -y install  perl perl-devel autoconf libaio numactl.x86_64 initscripts.x86_64
    if [[ ! -d $INSTALL_SRC_PATH ]];then
        mkdir $INSTALL_SRC_PATH
    fi
    cd $INSTALL_SRC_PATH/
    FILE=$INSTALL_SRC_PATH/mysql-5.6.39-linux-glibc2.12-x86_64.tar.gz
    if [[ -f "$FILE" ]]; then
        echo "$FILE exist"
    else
        `wget $FTPURL/mysql-5.6.39-linux-glibc2.12-x86_64.tar.gz --ftp-password=Zc134250.`
    fi
    tar -zxvf mysql-5.6.39-linux-glibc2.12-x86_64.tar.gz
    mv $INSTALL_SRC_PATH/mysql-5.6.39-linux-glibc2.12-x86_64  $MOD_MYSQL_INSTALL_PATH
    cd $MOD_MYSQL_INSTALL_PATH 
    groupadd mysql
    useradd -r -g mysql mysql
    #（mysql 启动时自动读取）
	cnf=$MOD_MYSQL_INSTALL_PATH/support-files/my-default.cnf
	if [[ -f $cnf ]];then
	echo "default-storage-engine=INNODB" >> $cnf
	echo "character_set_server=utf8" >> $cnf
    echo "skip-grant-tables=1" >> $cnf
	echo "[mysql]" >> $cnf
	echo "default-character-set=utf8" >> $cnf
	cp $MOD_MYSQL_INSTALL_PATH/support-files/my-default.cnf /etc/my.cnf
	fi
	mysf=$MOD_MYSQL_INSTALL_PATH/support-files/mysql.server
	if [[ -f $mysf ]];then
	sed -i "s@^basedir=@basedir=/usr/local/mysql@" $RDF
	sed -i "s@^datadir=@datadir=/usr/local/mysql/data@" $RDF
	cp $mysf /etc/init.d/mysql
    printf "cp $mysf /etc/init.d/mysql"
	fi
    #设置mysql系统环境变量
    echo "#设置mysql系统环境变量" >>$INSTALL_PATH/install.info
    if [ 0"$MYSQL_HOME" = "0" ];then
		echo "export MYSQL_HOME=$MOD_MYSQL_INSTALL_PATH" >> /etc/profile
	    echo "export PATH=\$PATH:\$MYSQL_HOME/bin" >> /etc/profile
	     . /etc/profile
    fi
	#给目录/usr/local/mysql 更改拥有者 
    printf "#给目录/usr/local/mysql 更改拥有者 " 
	chown -R mysql:mysql $MOD_MYSQL_INSTALL_PATH
    chkconfig --add mysql
    chkconfig mysql on
	cd $MOD_MYSQL_INSTALL_PATH/scripts
	./mysql_install_db  --user=mysql  --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data
	ln -s /usr/local/mysql/bin/mysql /usr/local/bin/mysql
    chkconfig --add mysql
    chkconfig mysql on
    printf "启动mysql service mysql start..." 
    service mysql start
    printf "启动mysql完成！！"   
    printf "进入mysql。。。。" 
    mysql  -uroot -p123456 --connect-expired-password <<EOF
    use mysql;
    update user set password=password(123456) where user='root' and host='localhost';
	flush privileges;
    exit
EOF
    printf "#禁用跳过密码" 
    sed -i "s@^skip-grant-tables=1@#skip-grant-tables=1@" /etc/my.cnf
    printf "重启mysql......." 
    service mysql restart
    printf "重启mysql完成！！！"
    printf "再次进入mysql开启远程连接。。。。"
    mysql  -uroot -p123456 --connect-expired-password <<EOF
    flush privileges;
    GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '123456' WITH GRANT OPTION;
    exit
EOF
    service mysql stop
    printf "设置mysql 账号：root密码：123456；开启远程连接；关闭无密码登陆，关闭mysql"
    # ============================

    printf "
   
MYSQL Install Information
=========================
MYSQL Version: 5.6.39
MYSQL Install Path: $MOD_MYSQL_INSTALL_PATH
Created: `date`
-------------------------
 "
    # ============================
}
