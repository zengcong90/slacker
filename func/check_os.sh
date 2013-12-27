#!/bin/bash
# Author:  Allen <movoin@gmail.com>
# Website:  http://movoin.com
#

if [ -f /etc/redhat-release ];then
    OS=CentOS
elif [ ! -z "`cat /etc/issue | grep Debian`" ];then
    OS=Debian
elif [ ! -z "`cat /etc/issue | grep Ubuntu`" ];then
    OS=Ubuntu
else
    echo -e "\033[31mDoes not support this OS, Please contact the author! \033[0m"
    kill -9 $$
fi

OS_command()
{
    if [ $OS == 'CentOS' ];then
        echo -e $OSCMD | bash
        OSCMD=""
    else
        echo -e "\033[31mDoes not support this OS, Please contact the author! \033[0m"
        kill -9 $$
    fi
}
