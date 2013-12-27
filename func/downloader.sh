#!/bin/bash
# Author:  Allen <movoin@gmail.com>
# Website:  http://movoin.com
#

Download_To_Src()
{
    cd $INSTALL_PATH/src/
    echo "Start download..."
    for i in $*; do
        [ -s "${i##*/}" ] && echo "Skiped ${i##*/} ..." || `wget -c --no-check-certificate $i`
    done
}
