#!/usr/bin/bash

arr=(HMASM ERP019800 SRA045646 SRA050230 SRP115494_gut HMP_stool_assembly)
for id in ${arr[@]}
do
    #intact=$(grep DGR $id-rebuild.gtf |wc -l)
    #all=$(grep DGR $id.gtf |wc -l)
    #partial=`echo "scale=0; $all - $intact" | bc`
    #echo -e "$intact\t$partial"
    #grep "RT" $id-rebuild.gtf |awk '{print ">"$1"\n"$6}' >$id-inatct-RT.fa
    #cd-hit-est -i $id-inatct-RT.fa -c 0.9 -o $id-inatct-RT-cdhit0.9.fa
    #num=$(grep ">" $id-inatct-RT-cdhit0.9.fa |wc -l)
    #echo -e "$id\t$num"
    #grep "\sDGR\s" $id-rebuild.gtf |awk '{print $1}' |sort |uniq >>$id-partialConfirmed-intact.id
    #cat partial/$id/filterCoverage/search_noRepeat_cov_2.out |grep -v ID |awk '{print $1}' |sort |uniq >>$id-partialConfirmed-intact.id
    ./reBuildDGR_pthread.pl $id.gtf $id-partialConfirmed-intact.fa $id-rebuild.gtf 0.5 3 30 30
done
exit
