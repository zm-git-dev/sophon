#!/usr/bin/bash

#k-fold cross validation, k=10
./splitData.pl dataSet/merged.gtf dataSet/merged.DGR.fa dataSet/merged.DGR.fa train/ test/ 10

muscle -in train/TR.fa -out classify/classify_TR/TR.muscle
muscle -in train/VR.fa -out classify/classify_VR/VR.muscle
muscle -in train/RT.fa -out classify/classify_RT/RT.muscle

FastTreeMP -nt classify/classify_TR/TR.muscle > classify/classify_TR/TR.muscle.tree
FastTreeMP -nt classify/classify_VR/VR.muscle > classify/classify_VR/VR.muscle.tree
FastTreeMP -nt classify/classify_RT/RT.muscle > classify/classify_RT/RT.muscle.tree
