#!/usr/bin/bash

group=$1

sh runSimulation2.sh $group/align/RT-class1.align $group/classify/classify_RT/class1.fa $2 $group/simulation/RT-class1.sml tmp-$group
sh runSimulation2.sh $group/align/RT-class2.align $group/classify/classify_RT/class2.fa $3 $group/simulation/RT-class2.sml tmp-$group
sh runSimulation2.sh $group/align/RT-class3.align $group/classify/classify_RT/class3.fa $4 $group/simulation/RT-class3.sml tmp-$group


sh runSimulation.sh $group/align/TR-class1.align $group/classify/classify_TR/class1.fa $5 $group/simulation/TR-class1.sml tmp-$group
sh runSimulation.sh $group/align/TR-class2.align $group/classify/classify_TR/class2.fa $6 $group/simulation/TR-class2.sml tmp-$group
sh runSimulation.sh $group/align/TR-class3.align $group/classify/classify_TR/class3.fa $7 $group/simulation/TR-class3.sml tmp-$group

sh runSimulation.sh $group/align/VR-class1.align $group/classify/classify_VR/class1.fa $8 $group/simulation/VR-class1.sml tmp-$group
sh runSimulation.sh $group/align/VR-class2.align $group/classify/classify_VR/class2.fa $9 $group/simulation/VR-class2.sml tmp-$group
sh runSimulation.sh $group/align/VR-class3.align $group/classify/classify_VR/class3.fa $10 $group/simulation/VR-class3.sml tmp-$group
