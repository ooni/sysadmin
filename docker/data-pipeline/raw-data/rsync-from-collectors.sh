#!/bin/bash
list=$1
dest=$2
while read line           
do           
 rsync -av $line $dest
done <$list
