#!/usr/bin/bash

for i in group_*/simulation/RT*sml
do
    head=$(awk '{if($5<=0.0005){print $0}}' $i |sort -rk4,4 -k5n,5 |head -1)
    echo -e "$i\t$head"
done

for i in group_*/simulation/VR*sml
do
    head=$(awk '{if($5<=0.001){print $0}}' $i |sort -rk4,4 -k5n,5 |head -1)
    echo -e "$i\t$head"
done

for i in group_*/simulation/TR*sml
do
    head=$(awk '{if($5<=0.001){print $0}}' $i |sort -rk4,4 -k5n,5 |head -1)
    echo -e "$i\t$head"
done
