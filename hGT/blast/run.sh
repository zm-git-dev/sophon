#!/bin/bash

for obj in `cat non-mammal.txt`
do
    grep -v "#" seg30M-$obj.blastn |awk '{if($4>=500){print $0}}' >non-mammal/$obj-500bp.out
done



exit
