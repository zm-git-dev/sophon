#!/usr/bin/bash

#arr=(bacteria ERP019800 HMASM HMP_stool_assembly SRA045646 SRA050230 SRP115494_gut)
#arr=(ERP019800 HMASM SRA045646 SRA050230 SRP115494_gut HMP_stool_assembly )
arr=(ERP019800 HMASM SRA045646 SRA050230 SRP115494)

for i in ${arr[@]}
do
    grep "\sRT\s" $i-rebuild.gtf |awk '{print ">"$1"\n"$6}' >1.fa
    grep "\sRT\s" $i-partial-confirmed.gtf |awk '{print ">"$1"\n"$7}' >2.fa
    cat 1.fa 2.fa >$i-intact-partial-confirmed-RT.fa
    cd-hit-est -i $i-intact-partial-confirmed-RT.fa -c 0.9 -o $i-intact-partial-confirmed-RT-cdhit0.9.fa
    rm 1.fa 2.fa
    #awk '{print $1}' $i-rebuild.gtf |sort |uniq >$i-intact.id
    #./../hitNoGTF.pl $i.gtf $i-intact.id $i-partial.gtf
    #cp $i-rebuild.gtf copy/$i-intact.gtf
    #mv $i-partial.gtf copy
    #grep "\sRT\s" $i.gtf |awk '{print $1}' |sort |uniq >mm-$i
    #filterFa ~/dGR/data/$i.fa mm-$i $i-dgrContaining.fa
    #cat ../partial/$i/filterCoverage/search_noRepeat_cov_2.out |grep -v "ID" |awk '{print $1}' |sort |uniq >$i-partial-confirmed.id
    #./../hitGTF.pl $i.gtf $i-partial-confirmed.id $i-partial-confirmed.gtf
    #cat $i-rebuild.gtf $i-partial-confirmed.gtf >$i-intact-partial-confirmed.gtf
done

exit
