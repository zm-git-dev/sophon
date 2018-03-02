#!/usr/bin/bash

muscle -in classify/classify_RT/RT_class1.fa -out tmp.txt
chomp tmp.txt
grep -v ">" tmp.txt >align/RT_class1.align
rm tmp.txt

muscle -in classify/classify_RT/RT_class2.fa -out tmp.txt
chomp tmp.txt
grep -v ">" tmp.txt >align/RT_class2.align
rm tmp.txt

muscle -in classify/classify_RT/RT_class3.fa -out tmp.txt
chomp tmp.txt
grep -v ">" tmp.txt >align/RT_class3.align
rm tmp.txt
