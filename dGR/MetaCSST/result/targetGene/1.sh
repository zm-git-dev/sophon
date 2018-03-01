#!/usr/bin/bash

for id in `cat 1.txt`
do
    num=$(grep "$id\s" ORF-1st.info |wc -l)
    echo -e "$id\t$num";
done
exit
