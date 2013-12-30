#!/bin/bash
#
# Common Helper File
#
# Author:  Allen <movoin@gmail.com>
# Website:  http://movoin.com
#

download()
{
    echo "Start download..."
    for i in $*; do
        [ -s "${i##*/}" ] && echo "Skiped ${i##*/} ..." || `wget -c --no-check-certificate $i`
    done
}
