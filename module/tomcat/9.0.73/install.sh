#!/bin/bash
#
# Module: TOMCAT
# Version: 3.4.10
#
# Author:  zengcong
# Website:  http://zsxhkj.com
#

install_tomcat()
{
    . $IN_PWD/GLOBAL.conf
    . $IN_PWD/utils/helper.sh
    . $IN_PWD/utils/installer.sh 
    cd $INSTALL_SRC_PATH/
    FILE=$INSTALL_SRC_PATH/apache-tomcat-9.0.73.tar.gz
    if [[ -f "$FILE" ]]; then
        echo "$FILE exist"
    else
        `wget $FTPURL/apache-tomcat-9.0.73.tar.gz --ftp-password=Zc134250.`
    fi
    tar -zxvf apache-tomcat-9.0.73.tar.gz
    mv $INSTALL_SRC_PATH/apache-tomcat-9.0.73  $MOD_TOMCAT_INSTALL_PATH
    TMS=/usr/lib/systemd/system/tomcat.service
    if [ ! -f "$TMS" ]; then
        sed -i "s@^# Make sure prerequisite environment variables are set@# Make sure prerequisite environment variables are set\\nexport JAVA_HOME=/opt/slacker/bin/jdk@" $MOD_TOMCAT_INSTALL_PATH/bin/setclasspath.sh
        sed -i "s@^cygwin=false@CATALINA_PID=$MOD_TOMCAT_INSTALL_PATH/pid\\ncygwin=false@" $MOD_TOMCAT_INSTALL_PATH/bin/catalina.sh
        touch $TMS
        echo  "[Unit]" >> $TMS
        echo  "Description=tomcat" >> $TMS
        echo  "After=network.target" >> $TMS
        echo  "[Service]" >> $TMS  
        echo  "Environment=/opt/slacker/bin/jdk/bin" >> $TMS  
        echo  "WorkingDirectory=$MOD_TOMCAT_INSTALL_PATH" >> $TMS 
        echo  "PIDFile=$MOD_TOMCAT_INSTALL_PATH/pid" >> $TMS 
        echo  "ExecStart=$MOD_TOMCAT_INSTALL_PATH/bin/startup.sh" >> $TMS 
        echo  "ExecReload=/bin/kill -s HUP \$MAINPID" >> $TMS 
        echo  "ExecStop=/bin/kill -s QUIT \$MAINPID" >> $TMS 
        echo  "PrivateTmp=true" >> $TMS 
        echo  "Type=simple" >> $TMS
        echo  "User=root" >> $TMS
        echo  "Group=root" >> $TMS
        echo  "SyslogIdentifier=tomcat-api" >> $TMS
        echo  "[Install]" >> $TMS 
        echo  "WantedBy=multi-user.target" >> $TMS     
        chmod 777 $TMS
        systemctl daemon-reload
        systemctl enable tomcat
        systemctl is-enabled tomcat
    fi
    # ============================

    printf "

TOMCAT Install Information
=========================
TOMCAT Version: 9.0.73
TOMCAT Install Path: $MOD_TOMCAT_INSTALL_PATH
Created: `date`
-------------------------
 "
    # ============================
}
