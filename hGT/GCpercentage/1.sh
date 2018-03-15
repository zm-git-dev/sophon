#!/usr/bin/bash

for i in *txt
do
    pre=${i%.txt}
    awk '{print $0"\t"$4+$5"\t'$pre'"}' $i >>gc.txt
done
exit

##ggplot2 code for boxplot:
#ggplot(data)+geom_boxplot(aes(x=type,y=GCpercentage,fill=type))+labs(x="")+theme(axis.text.x = element_blank(),legend.title=element_blank(),legend.text=element_text(size=18),axis.text=element_text(size=18),axis.title=element_text(size=18))