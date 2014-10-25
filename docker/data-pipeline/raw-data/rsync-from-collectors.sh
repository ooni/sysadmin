#!/bin/bash
dest=$1
while read line           
do           
 rsync -ave ssh $line $dest
done <collectors-conf.sh
