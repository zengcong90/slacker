#!/bin/bash
#
# Module: ERLANG
# Version: 4.0.0
#
# Author:  zengcong
# Website:  http://zsxhkj.com
#

install_erlang()
{
    . $IN_PWD/GLOBAL.conf
    . $IN_PWD/utils/helper.sh
    . $IN_PWD/utils/installer.sh 
    cd $INSTALL_SRC_PATH/
#安装依赖包
yum -y install m4-1.4.16-10.el7.x86_64
yum -y install flex-2.5.37-6.el7.x86_64
yum -y install byacc-1.9.20130304-3.el7.x86_64
yum -y install ncurses-devel-5.9-14.20130511.el7_4.x86_64
#判断unixODBC-2.2.1安装包存在
UFILE=$INSTALL_SRC_PATH/unixODBC-2.2.1.tar.gz
if [[ -f "$UFILE" ]]; then
    echo "$UFILE exist"
else
    `wget $FTPURL/unixODBC-2.2.1.tar.gz --ftp-password=Zc134250.`
fi
#解压断unixODBC-2.2.1安装包
tar -zxvf unixODBC-2.2.1.tar.gz
mv $INSTALL_SRC_PATH/unixODBC-2.2.1  $INSTALL_BIN_PATH/unixODBC-2.2.1
cd $INSTALL_BIN_PATH/unixODBC-2.2.1
./configure --prefix=$INSTALL_BIN_PATH/unixODBC-2.2.1 --includedir=/usr/include --libdir=/usr/lib -bindir=/usr/bin --sysconfdir=/etc --enable-gui=no
 
#判断erlang安装包存在
    cd $INSTALL_SRC_PATH/
    FILE=$INSTALL_SRC_PATH/otp_src_17.5.tar.gz
    if [[ -f "$FILE" ]]; then
        echo "$FILE exist"
    else
        `wget $FTPURL/otp_src_17.5.tar.gz --ftp-password=Zc134250.`
    fi
    #解压断erlang安装包
    tar -zxvf otp_src_17.5.tar.gz
    mv $INSTALL_SRC_PATH/otp_src_17.5  $MOD_ERLANG_INSTALL_PATH
    cd $MOD_ERLANG_INSTALL_PATH

#设置erlang系统环境变量
    if [ 0"$ERLANG_HOME" = "0" ];then
		echo "export ERLANG_HOME=$MOD_ERLANG_INSTALL_PATH" >> /etc/profile
	    echo "export PATH=\$PATH:\$ERLANG_HOME/bin" >> /etc/profile
	     . /etc/profile
    fi
    ln -s $MOD_ERLANG_INSTALL_PATH/bin/erl /usr/bin/erl
    ./configure --prefix=$MOD_ERLANG_INSTALL_PATH --without-javac
    make && make install
    if [ -d "$MOD_ERLANG_INSTALL_PATH" ];then
        echo -e "\033[32mMONGODB install successfully! \033[0m"
    else
        echo -e "\033[31mMONGODB install failed, Please contact the author! \033[0m"
        kill -9 $$
    fi
    # ============================

    printf "

ERLANG Install Information
=========================
ERLANG Version: 17.5
ERLANG Install Path: $MOD_ERLANG_INSTALL_PATH
Created: `date`
-------------------------
 "
    # ============================
}
