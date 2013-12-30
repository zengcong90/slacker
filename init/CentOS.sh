#!/bin/bash
#
# CentOS Init Environment
#
# Author:  Allen <movoin@gmail.com>
# Website:  http://movoin.com
#

# yum.repo
yum clean all

# 163 Repo
# mv /etc/yum.repos.d/CentOS-Base.repo $INSTALL_BACKUP_PATH/CentOS-Base.repo

yum -y install wget
# if [ ! -z "$(cat /etc/redhat-release | grep '6\.')" ];then
#     wget -c --no-check-certificate http://mirrors.163.com/.help/CentOS6-Base-163.repo -P /etc/yum.repos.d
#     mv /etc/yum.repos.d/CentOS6-Base-163.rep /etc/yum.repos.d/CentOS-Base.repo
#     sed -i 's@\$releasever@6@g' /etc/yum.repos.d/CentOS-Base.repo
#     sed -i 's@gpgcheck=1@gpgcheck=0@g' /etc/yum.repos.d/CentOS-Base.repo
# fi

# if [ ! -z "$(cat /etc/redhat-release | grep '5\.')" ];then
#     wget -c --no-check-certificate http://mirrors.163.com/.help/CentOS5-Base-163.repo -P /etc/yum.repos.d
#     mv /etc/yum.repos.d/CentOS5-Base-163.rep /etc/yum.repos.d/CentOS-Base.repo
#     sed -i 's@\$releasever@5@g' /etc/yum.repos.d/CentOS-Base.repo
#     sed -i 's@gpgcheck=1@gpgcheck=0@g' /etc/yum.repos.d/CentOS-Base.repo
# fi

yum makecache

# Remove Default Packages
if [ ! -z "$(cat /etc/redhat-release | grep '6\.')" ];then
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

# Install needed packages
yum -y install gcc \
    gcc-c++ \
    make \
    autoconf \
    libjpeg \
    libjpeg-devel \
    libpng \
    libpng-devel \
    freetype \
    freetype-devel \
    libxml2 \
    libxml2-devel \
    zlib \
    zlib-devel \
    glibc \
    glibc-devel \
    glib2 \
    glib2-devel \
    bzip2 \
    bzip2-devel \
    ncurses \
    ncurses-devel \
    curl \
    curl-devel \
    e2fsprogs \
    e2fsprogs-devel \
    krb5-devel \
    libidn \
    libidn-devel \
    openssl \
    openssl-devel \
    nss_ldap \
    openldap \
    openldap-devel \
    openldap-clients \
    openldap-servers \
    libxslt-devel \
    libevent-devel \
    libtool \
    libtool-ltdl \
    bison \
    gd-devel \
    vim-enhanced \
    pcre-devel \
    zip \
    unzip \
    ntpdate \
    sysstat \
    patch

# use gcc-4.4
if [ ! -z "`gcc --version | head -n1 | grep 4\.1`" ];then
        yum -y install gcc44 gcc44-c++ libstdc++44-devel
    export CC="gcc44" CXX="g++44"
fi

# install sendmail
if [ ! -e "`which sendmail`" ];then
    yum -y install sendmail && service sendmail restart
fi

# closed Unnecessary services and remove obsolete rpm package
for Service in `chkconfig --list | grep 3:on | awk '{print $1}'`;do chkconfig --level 3 $Service off;done
for Service in sshd network crond iptables irqbalance syslog rsyslog sendmail;do chkconfig --level 3 $Service on;done

# Set DNS
cat > /etc/resolv.conf << EOF
nameserver 114.114.114.114
nameserver 8.8.8.8
EOF

service network restart

# Close SELINUX
setenforce 0
sed -i 's/^SELINUX=.*$/SELINUX=disabled/' /etc/selinux/config

# initdefault
sed -i 's/^id:.*$/id:3:initdefault:/' /etc/inittab
init q

# history size
sed -i 's/^HISTSIZE=.*$/HISTSIZE=100/' /etc/profile
[ -z "`cat ~/.bashrc | grep history-timestamp`" ] && echo "export PROMPT_COMMAND='{ msg=\$(history 1 | { read x y; echo \$y; });user=\$(whoami); echo \$(date \"+%Y-%m-%d %H:%M:%S\"):\$user:\`pwd\`/:\$msg ---- \$(who am i); } >> /tmp/\`hostname\`.\`whoami\`.history-timestamp'" >> ~/.bashrc

# IPV6
cat > /etc/sysconfig/network << EOF
NETWORKING=yes
NETWORKING_IPV6=no
EOF

# Set timezone
rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# Update time
ntpdate pool.ntp.org
echo "*/20 * * * * `which ntpdate` pool.ntp.org > /dev/null 2>&1" > /var/spool/cron/root;chmod 600 /var/spool/cron/root
service crond restart

# iptables
cat > /etc/sysconfig/iptables << EOF
# Firewall configuration written by system-config-securitylevel
# Manual customization of this file is not recommended.
*filter
:INPUT DROP [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:syn-flood - [0:0]
-A INPUT -i lo -j ACCEPT
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
-A INPUT -p icmp -m limit --limit 100/sec --limit-burst 100 -j ACCEPT
-A INPUT -p icmp -m limit --limit 1/s --limit-burst 10 -j ACCEPT
-A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j syn-flood
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A syn-flood -p tcp -m limit --limit 3/sec --limit-burst 6 -j RETURN
-A syn-flood -j REJECT --reject-with icmp-port-unreachable
COMMIT
EOF
service iptables restart

# install htop
. $IN_PWD/utils/helper.sh

if [ ! -e "`which htop`" ];then
    cd $INSTALL_SRC_PATH/
    download "http://downloads.sourceforge.net/project/htop/htop/1.0.2/htop-1.0.2.tar.gz"
    tar xzf htop-1.0.2.tar.gz
    cd htop-1.0.2
    ./configure
    make && make install
    cd $INSTALL_SRC_PATH/
fi

. /etc/profile
. ~/.bashrc

[ ! -z "`gcc --version | head -n1 | grep 4\.1`" ] && export CC="gcc44" CXX="g++44"
