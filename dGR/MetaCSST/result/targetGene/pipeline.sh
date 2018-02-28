#!/usr/bin/bash

## ORF finding
#translate 40 core-intact.fa

## hitVR:get the location relationship between VRs and ORFs
./hitVR.pl VR-unique.info ORF.info overlap.info

## sort overlap.info
cat overlap.info |sort -k1,1 -k2,2 -k3n,3 -k4n,4 >mm
mv mm overlap.info

## move overlap redundancy, only the longest overlapped ORF will be retained for each VR
./mvRedundancy.pl overlap.info overlap-longest.info

## get the target genes of the longest ORFs
awk '{print $5}' overlap-longest.info  |sort |uniq >targetGene.id
filterFa ORF.pro targetGene.id targetGene.fa

## summarize for multiVRs--ORFs overlap
./summaryMultiVR.pl overlap-longest.info multiVR.id overlap-longest-multiVRs.info >multiVR-target.count.txt

## Blastp to GO database
blastp -query targetGene.fa -db /share/data/HMP/background/go_weekly-seqdb.fa -out targetGene-GO.blastp -num_threads 40 -evalue 1e-5

## get BLASTP top1 hit
getHit targetGene-GO.blastp
grep -A 1 ">" targetGene-GO.blastp.out |grep -v ">" |grep -v "\-\-$" |awk '{print $1}' |sort |uniq >targetGene-GO.blastp-top1.hit

## get hit GO terms
./getGO.pl targetGene-GO.blastp-top1.hit /share/data/HMP/background/go_weekly-seqdb.fa targetGene-GO.blastp-top1-symbol2GO.txt


###GO enrichment && FDR calculation
./getCommonTerm.pl targetGene-GO.blastp-uniprot.txt common-uniprot.id targetGene-GO.blastp-uniprot-common.txt
awk '{print $2}' targetGene-GO.blastp-uniprot-common.txt |sort |uniq >targetGene-GO.blastp-uniprot.GOterm.txt
./p_value.pl GOterm-frequency.txt GOA.txt |sort -nk 4 >p_value.txt
grep -v "P_value" p_value.txt |awk -F '\t' '{print $1"\t"$2"\t"$3"\t"$4"\t"$4*408/NR"\t"$5"\t"$6}' >q_value.txt