### A example pipeline to identify DGRs in 29 known DGRs from human gut virome
    #chomp example/hv29.fa
    ./MetaCSSTmain -build arg.config -in example/hv29.fa -out example/out_tmp1 -thread 4
    perl src/callVR.pl example/out_tmp1/raw.gtf example/hv29.fa example/out_tmp2
    perl src/removeRepeat.pl example/out_tmp2 example/out-DGR.gtf
    