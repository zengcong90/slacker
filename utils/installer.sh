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

# install_mod $moduleName $version
install_mod()
{
    if [ -d "$MOD_PWD/$1" ]; then
        if [ ! -s "$MOD_PWD/$1/$2/install.lock" ]; then
            chmod +x $MOD_PWD/$1/$2/install.sh
            . $MOD_PWD/$1/$2/install.sh
            # @TODO Determine if there is a file directory
            if [ -d "$MOD_PWD/$1/$2/src/" ];then
                cp -fr $MOD_PWD/$1/$2/src/*.* $INSTALL_PATH/src/
            fi
            echo "Start install module $1..."
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
        if [ ! -s "$EXT_PWD/$1/install.lock" ]; then
            chmod +x $EXT_PWD/$1/install.sh
            . $EXT_PWD/$1/install.sh
            # @TODO Determine if there is a file directory
            if [ -d "$EXT_PWD/$1/src/" ];then
                cp -fr $EXT_PWD/$1/src/*.* $INSTALL_PATH/src/
            fi
            echo "Start install php extension $1..."
            "install_ext_$1" 2>&1 | tee -a $INSTALL_PATH/install.log
            touch $EXT_PWD/$1/install.lock
        fi
    fi
}

# install_phplib $lib_name
install_phplib()
{
    if [ -d "$LIB_PWD/$1" ]; then
        if [ ! -s "$LIB_PWD/$1/install.lock" ]; then
            chmod +x $LIB_PWD/$1/install.sh
            . $LIB_PWD/$1/install.sh
            # @TODO Determine if there is a file directory
            if [ -d "$LIB_PWD/$1/src/" ];then
                cp -fr $LIB_PWD/$1/src/*.* $INSTALL_PATH/src/
            fi
            echo "Start install php library $1..."
            "install_lib_$1" 2>&1 | tee -a $INSTALL_PATH/install.log
            touch $LIB_PWD/$1/install.lock
        fi
    fi
}
