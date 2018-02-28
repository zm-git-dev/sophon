#!/usr/bin/bash

#cat MetaCSST.log.info |grep "MetaCSST end" |awk '{print $5}' |awk -F ':' '{print $1*60+$2-927}' |awk '{sum += $1};END {print sum}'

cat *log |grep RT155 |grep end |awk '{print $5}' |awk -F ':' '{print $1*60+$2-1165}' |awk '{sum += $1};END {print sum+16*24*60}'

start=$(cat *log |grep RT367 |grep start |awk '{print $5}' |awk -F ':' '{print $1*60+$2}' |awk '{sum += $1};END {print sum+16*24*60}')
end=$(cat *log |grep RT367 |grep end |awk '{print $5}' |awk -F ':' '{print $1*60+$2}' |awk '{sum += $1};END {print sum+30*24*60}')
echo -e "$end\t-\t$start"

start=$(cat *log |grep RT1246 |grep start |awk '{print $5}' |awk -F ':' '{print $1*60+$2}' |awk '{sum += $1};END {print sum}')
end=$(cat *log |grep RT1246 |grep end |awk '{print $5}' |awk -F ':' '{print $1*60+$2}' |awk '{sum += $1};END {print sum}')
echo -e "$end\t-\t$start"