#!/usr/bin/bash

arr=(9 18 27 36 45 54 63 72 81 90)
for i in ${arr[@]}
do
    result=$(find group_*/classify/ |grep "class" |grep "txt" |xargs wc -l |awk '{print $1}' |head -$i |tail -n 9 |tr "\n" " ")
    echo "nohup sh simulation.sh group_ $result &"
done
exit