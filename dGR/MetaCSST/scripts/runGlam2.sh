#!/usr/bin/bash

./glam2.pl  classify/classify_TR/TR_class1.fa align/TR_class1.align motif/motif_TR_class1
./glam2.pl  classify/classify_TR/TR_class2.fa align/TR_class2.align motif/motif_TR_class2
./glam2.pl  classify/classify_TR/TR_class3.fa align/TR_class3.align motif/motif_TR_class3

./glam2.pl  classify/classify_VR/VR_class1.fa align/VR_class1.align motif/motif_VR_class1
./glam2.pl  classify/classify_VR/VR_class2.fa align/VR_class2.align motif/motif_VR_class2
./glam2.pl  classify/classify_VR/VR_class3.fa align/VR_class3.align motif/motif_VR_class3
