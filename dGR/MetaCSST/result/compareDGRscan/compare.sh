#!/usr/bin/bash

for i in HMASM_split_*
do
    nohup sh runDGRscan.sh $i &
    #nohup sh runMetaCSST.sh $i &
done