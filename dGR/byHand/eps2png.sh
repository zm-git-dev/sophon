#!/usr/bin/bash

dir=$1
for i in $dir/*eps
do
    pre=${i%.eps}
    gs -dBATCH -dNOPAUSE -q -dEPSCrop -sDEVICE=png256 -sOutputFile=$pre.png $i
done