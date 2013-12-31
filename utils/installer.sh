#!/bin/bash
#
# Module Installer
#
# Author:  Allen <movoin@gmail.com>
# Website:  http://movoin.com
#

MOD_PWD="$IN_PWD/module"
EXT_PWD="$MOD_PWD/php-extends"
LIB_PWD="$MOD_PWD/php-libraries"

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

# install_phpext $extend_name
install_phpext()
{
    if [ -d "$EXT_PWD/$1" ]; then
        if [ ! -f "$EXT_PWD/$1/install.lock" ]; then
            chmod +x $EXT_PWD/$1/*.sh
            . $EXT_PWD/$1/install.sh
            cp_to_src "$EXT_PWD/$1/src"
            echo "====> Start install php extension $1..." | tee -a $INSTALL_PATH/install.log
            "install_ext_$1" 2>&1 | tee -a $INSTALL_PATH/install.log
            touch $EXT_PWD/$1/install.lock
        fi
    fi
}

# install_phplib $lib_name
install_phplib()
{
    if [ -d "$LIB_PWD/$1" ]; then
        if [ ! -f "$LIB_PWD/$1/install.lock" ]; then
            chmod +x $LIB_PWD/$1/*.sh
            . $LIB_PWD/$1/install.sh
            cp_to_src "$LIB_PWD/$1/src"
            echo "====> Start install php library $1..." | tee -a $INSTALL_PATH/install.log
            "install_lib_$1" 2>&1 | tee -a $INSTALL_PATH/install.log
            touch $LIB_PWD/$1/install.lock
        fi
    fi
}
