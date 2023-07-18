#!/bin/bash
#
# Module: jdk
# Version: 1.8
#
# Author:  zengcong
# Website:  http://www.zsxhkj.com
#

install_jdk()
{
    . $IN_PWD/GLOBAL.conf
    . $IN_PWD/utils/helper.sh
    . $IN_PWD/utils/installer.sh

    if [ ! -e "`which cmake`" ];then
        yum -y install cmake
    fi 
    cd $INSTALL_SRC_PATH/
    FILE=$INSTALL_SRC_PATH/jdk-8u301-linux-x64.tar.gz
    if [[ -f "$FILE" ]];then
        echo "$FILE exist"
    else
        `wget $FTPURL/jdk-8u301-linux-x64.tar.gz --ftp-password=Zc134250.`
    fi
    tar -zxvf jdk-8u301-linux-x64.tar.gz
    mv $INSTALL_SRC_PATH/jdk1.8.0_301  $INSTALL_BIN_PATH/jdk
    if [ -d "$MOD_JDK_INSTALL_PATH" ];then
        echo -e "\033[32mJDK install successfully! \033[0m"
    else
        echo -e "\033[31mJDK install failed, Please contact the author! \033[0m"
        kill -9 $$
    fi
    if [ 0"$JAVA_HOME" = "0" ];then
		 echo "export JAVA_HOME=$MOD_JDK_INSTALL_PATH" >> /etc/profile
	     echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> /etc/profile
	     . /etc/profile
    fi
    # ============================
	
    printf "

JDK Install Information
=========================

"$JAVA_HOME"
JDK Install Path: $MOD_JDK_INSTALL_PATH
Created: `date`
-------------------------
 " >> $INSTALL_PATH/install.info
    # ============================
}
