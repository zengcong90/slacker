#!/bin/bash
#
# Module: maven
# Version: 3.6.1
#
# Author:  zengcong
# Website:  http://zsxhkj.com
#

install_maven()
{
    . $IN_PWD/GLOBAL.conf
    . $IN_PWD/utils/helper.sh
    . $IN_PWD/utils/installer.sh 
    cd $INSTALL_SRC_PATH/
    FILE=$INSTALL_SRC_PATH/apache-maven-3.6.1.tar
    if [[ -f "$FILE" ]]; then
        echo "$FILE exist"
    else
        `wget $FTPURL/apache-maven-3.6.1.tar --ftp-password=Zc134250.`
    fi
    tar xvf apache-maven-3.6.1.tar
    mv $INSTALL_SRC_PATH/apache-maven-3.6.1  $INSTALL_BIN_PATH/maven
    if [ ! -d "$MOD_MAVEN_INSTALL_PATH/ck" ];then
        mkdir $MOD_MAVEN_INSTALL_PATH/ck
    fi
    if [ -d "$MOD_MAVEN_INSTALL_PATH" ];then
        echo -e "\033[32mMAVEN install successfully! \033[0m"
    else
        echo -e "\033[31mMAVEN install failed, Please contact the author! \033[0m"
        kill -9 $$
    fi
    if [ 0"$MAVEN_HOME" = "0" ]; then
        echo "export MAVEN_HOME=$MOD_MAVEN_INSTALL_PATH" >> /etc/profile
        echo "export PATH=\$PATH:$MOD_MAVEN_INSTALL_PATH/bin" >> /etc/profile
        . /etc/profile
    fi
    sed -i "s@^  <!-- localRepository@<localRepository>$MOD_MAVEN_INSTALL_PATH/ck</localRepository>\\n  <!-- localRepository@"   $MOD_MAVEN_INSTALL_PATH/conf/settings.xml
	sed -i "s@^  <mirrors>@<mirrors>\\n  <mirror>\\n   <id>alimaven</id>\\n   <name>aliyun maven</name>\\n    <url>http://maven.aliyun.com/nexus/content/groups/public/</url>\\n   <mirrorOf>central</mirrorOf>\\n  </mirror>@" $MOD_MAVEN_INSTALL_PATH/conf/settings.xml
    # ============================

    printf "

MAVEN Install Information
=========================
MAVEN Version: 3.6.1
MAVEN Install Path: $MOD_MAVEN_INSTALL_PATH
Created: `date`
-------------------------
 "
    # ============================
}
