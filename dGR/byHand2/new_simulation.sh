#!/usr/bin/bash

group=$1

nohup sh runSimulation.sh $group/align/TR-class1.align $group/classify/classify_TR/class1.fa $2 $group/simulation/TR-class1.sml tmp-$group-1 &
nohup sh runSimulation.sh $group/align/TR-class2.align $group/classify/classify_TR/class2.fa $3 $group/simulation/TR-class2.sml tmp-$group-2 &
nohup sh runSimulation.sh $group/align/TR-class3.align $group/classify/classify_TR/class3.fa $4 $group/simulation/TR-class3.sml tmp-$group-3 &
nohup sh runSimulation.sh $group/align/TR-class4.align $group/classify/classify_TR/class4.fa $5 $group/simulation/TR-class4.sml tmp-$group-4 &
nohup sh runSimulation.sh $group/align/TR-class5.align $group/classify/classify_TR/class5.fa $6 $group/simulation/TR-class5.sml tmp-$group-5 &
nohup sh runSimulation.sh $group/align/TR-class6.align $group/classify/classify_TR/class6.fa $7 $group/simulation/TR-class6.sml tmp-$group-6 &


nohup sh runSimulation.sh $group/align/VR-class1.align $group/classify/classify_VR/class1.fa $8 $group/simulation/VR-class1.sml tmp-$group-7 &
nohup sh runSimulation.sh $group/align/VR-class2.align $group/classify/classify_VR/class2.fa $9 $group/simulation/VR-class2.sml tmp-$group-8 &
nohup sh runSimulation.sh $group/align/VR-class3.align $group/classify/classify_VR/class3.fa $10 $group/simulation/VR-class3.sml tmp-$group-9 &
nohup sh runSimulation.sh $group/align/VR-class4.align $group/classify/classify_VR/class4.fa $11 $group/simulation/VR-class4.sml tmp-$group-10 &
nohup sh runSimulation.sh $group/align/VR-class5.align $group/classify/classify_VR/class5.fa $12 $group/simulation/VR-class5.sml tmp-$group-11 &
nohup sh runSimulation.sh $group/align/VR-class6.align $group/classify/classify_VR/class6.fa $13 $group/simulation/VR-class6.sml tmp-$group-12 &
