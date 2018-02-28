#!/usr/bin.bash

for i in *gtf 
do
    pre=${i%.gtf}
    grep "\sRT\s" $i |awk '{print $1}' |sort |uniq >$pre.id
done
exit