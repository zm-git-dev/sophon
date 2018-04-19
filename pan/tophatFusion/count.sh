#!/bin/bash

for i in `awk '{print $1}' summaryHTML-3.out |sort |uniq`
do
    num=$(grep $i summaryHTML-3.out |wc -l)
    echo -e "$i\t$num"
done

