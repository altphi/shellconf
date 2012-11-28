#!/bin/sh
if [ $# -lt 1 ]
then
        echo "usage: $0 argument1"; exit 1;
else
sudo echo "rsync://`hostname`/$PWD/$1" | nc -w 3 127.0.0.1 38383
fi
