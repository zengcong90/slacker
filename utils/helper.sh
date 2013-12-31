#!/bin/bash
#
# Common Helper File
#
# Author:  Allen <movoin@gmail.com>
# Website:  http://movoin.com
#

. $IN_PWD/GLOBAL.conf

download()
{
    echo "Start download..."
    for i in $*; do
        [ -s "${i##*/}" ] && echo "Skiped ${i##*/} ..." || `wget -c --no-check-certificate $i`
    done
}

cp_to_src()
{
    [ -d "$1/" ] && [ "`ls -A $1/`" == ""  ] && cp -fr $1/*.* $INSTALL_PATH/src/
}
