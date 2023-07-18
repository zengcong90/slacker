#!/bin/bash
#
# CentOS Init Environment
#
# Author:  zengcong
# Website:  http://www.zsxhkj.com
#

# fastestmirror.conf
 sed -i 's@^enabled=1@enabled=0@' /etc/yum/pluginconf.d/fastestmirror.conf

# yum.repo
if [[ ! -f "/etc/yum.repos.d/CentOS-Base.repo" ]];then
    cd /etc/yum.repos.d
    `wget $FTPURL/Centos7-Base.repo --ftp-password=Zc134250.`
fi
yum clean all&&yum makecache
# ali Repo
if [ $IS_ALI_REPOS == 'y' ];then
    if [ ! -z "$(cat /etc/redhat-release | grep '7\.')" ];then
        mv /etc/yum.repos.d/CentOS-Base.repo $INSTALL_BACKUP_PATH/CentOS-Base.repo
        mv $IN_PWD/init/CentOS7-Base-ali.repo /etc/yum.repos.d/CentOS-Base.repo
        sed -i 's@\$releasever@7@g' /etc/yum.repos.d/CentOS-Base.repo
        sed -i 's@gpgcheck=1@gpgcheck=0@g' /etc/yum.repos.d/CentOS-Base.repo
    fi
    if [ ! -z "$(cat /etc/redhat-release | grep '6\.')" ];then
        mv /etc/yum.repos.d/CentOS-Base.repo $INSTALL_BACKUP_PATH/CentOS-Base.repo
        mv $IN_PWD/init/CentOS6-Base-163.rep /etc/yum.repos.d/CentOS-Base.repo
        sed -i 's@\$releasever@6@g' /etc/yum.repos.d/CentOS-Base.repo
        sed -i 's@gpgcheck=1@gpgcheck=0@g' /etc/yum.repos.d/CentOS-Base.repo
    fi

    if [ ! -z "$(cat /etc/redhat-release | grep '5\.')" ];then
        mv /etc/yum.repos.d/CentOS-Base.repo $INSTALL_BACKUP_PATH/CentOS-Base.repo
        mv $IN_PWD/init/CentOS5-Base-163.rep /etc/yum.repos.d/CentOS-Base.repo
        sed -i 's@\$releasever@5@g' /etc/yum.repos.d/CentOS-Base.repo
        sed -i 's@gpgcheck=1@gpgcheck=0@g' /etc/yum.repos.d/CentOS-Base.repo
    fi
fi

# Remove Default Packages
if [ ! -z "$(cat /etc/redhat-release | grep '7\.')" ];then
    yum -y groupremove "FTP Server" \
        "PostgreSQL Database client" \
        "PostgreSQL Database server" \
        "MySQL Database server" \
        "MySQL Database client" \
        "Web Server" \
        "Office Suite and Productivity" \
        "E-mail server" \
        "Ruby Support" \
        "X Window System" \
        "Printing client" \
        "Desktop*"
elif [ ! -z "$(cat /etc/redhat-release | grep '6\.')" ];then
    yum -y groupremove "FTP Server" \
        "PostgreSQL Database client" \
        "PostgreSQL Database server" \
        "MySQL Database server" \
        "MySQL Database client" \
        "Web Server" \
        "Office Suite and Productivity" \
        "E-mail server" \
        "Ruby Support" \
        "X Window System" \
        "Printing client" \
        "Desktop*"
elif [ ! -z "$(cat /etc/redhat-release | grep '5\.')" ];then
    yum -y groupremove \
        "FTP Server" \
        "Text-based Internet" \
        "Windows File Server" \
        "PostgreSQL Database" \
        "News Server" \
        "MySQL Database" \
        "DNS Name Server" \
        "Web Server" \
        "Dialup Networking Support" \
        "Mail Server" \
        "Ruby" \
        "Office/Productivity" \
        "Sound and Video" \
        "X Window System" \
        "X Software Development" \
        "Printing Support" \
        "OpenFabrics Enterprise Distribution"
fi

# Upgrade OS
yum check-update
[ "$IS_UPGRADE_OS" == 'y' ] && yum -y update

yum -y install wget

# Install needed packages
yum -y install gcc \
    gcc-c++ \
    make \
    ftp \
    automake \
    autoconf \
    libtool \
    centos-release-scl \
    devtoolset-7 \
    vim 

# closed Unnecessary services and remove obsolete rpm package
#for Service in `chkconfig --list | grep 3:on | awk '{print $1}'`;do chkconfig --level 3 $Service off;done
#for Service in sshd network crond iptables irqbalance syslog rsyslog sendmail;do chkconfig --level 3 $Service on;done

# Set DNS
# cat > /etc/resolv.conf << EOF
# nameserver 114.114.114.114
# nameserver 8.8.8.8
# EOF


# history size
sed -i 's/^HISTSIZE=.*$/HISTSIZE=100/' /etc/profile
[ -z "`cat ~/.bashrc | grep history-timestamp`" ] && echo "export PROMPT_COMMAND='{ msg=\$(history 1 | { read x y; echo \$y; });user=\$(whoami); echo \$(date \"+%Y-%m-%d %H:%M:%S\"):\$user:\`pwd\`/:\$msg ---- \$(who am i); } >> /tmp/\`hostname\`.\`whoami\`.history-timestamp'" >> ~/.bashrc


# Set timezone
rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

. /etc/profile
. ~/.bashrc

