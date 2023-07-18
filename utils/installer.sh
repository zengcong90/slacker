#!/bin/bash
#
# Module Installer
#
# Author:  Allen <movoin@gmail.com>
# Website:  http://movoin.com
#

MOD_PWD="$IN_PWD/module"
. $IN_PWD/utils/helper.sh

# install_mod $moduleName $version
install_mod()
{
    if [ -d "$MOD_PWD/$1" ]; then
        if [ ! -f "$MOD_PWD/$1/$2/install.lock" ]; then
            chmod +x $MOD_PWD/$1/$2/*.sh
            . $MOD_PWD/$1/$2/install.sh
            cp_to_src "$MOD_PWD/$1/$2/src"
            echo "====> Start install module $1..." | tee -a $INSTALL_PATH/install.log
            "install_$1" 2>&1 | tee -a $INSTALL_PATH/install.log
            touch $MOD_PWD/$1/$2/install.lock
        fi
    fi
}

# install shell
install_shell()
{
    if [ -s "$1" ];then
        chmod +x $1
        . $1 2>&1 | tee -a $INSTALL_PATH/install.log
        /bin/mv $1{,_lock}
    fi
}
