#!/bin/bash

arr=(GCA_000004035.1_Meug_1.1_genomic GCA_000152225.2_Pcap_2.0_genomic GCA_000164785.2_C_hoffmanni-2.0.1_genomic GCA_000180675.1_ASM18067v1_genomic GCA_000180735.1_ASM18073v1_genomic GCA_000181375.1_ASM18137v1_genomic GCA_000400755.1_version_1_of_Takifugu_flavidus_genome_genomic GCA_002833325.1_Pmar_germline_1.0_genomic GCF_000001635.26_GRCm38.p6_genomic GCF_000001895.5_Rnor_6.0_genomic GCF_000001905.1_Loxafr3.0_genomic GCF_000002035.6_GRCz11_genomic GCF_000002285.3_CanFam3.1_genomic GCF_000002295.2_MonDom5_genomic GCF_000002315.4_Gallus_gallus-5.0_genomic GCF_000003025.6_Sscrofa11.1_genomic GCF_000003055.6_Bos_taurus_UMD_3.1.1_genomic GCF_000003625.3_OryCun2.0_genomic GCF_000004195.3_Xenopus_tropicalis_v9.1_genomic GCF_000004335.2_AilMel_1.0_genomic GCF_000090745.1_AnoCar2.0_genomic GCF_000146605.2_Turkey_5.0_genomic GCF_000147115.1_Myoluc2.0_genomic GCF_000151735.1_Cavpor3.0_genomic GCF_000151805.1_Taeniopygia_guttata-3.2.4_genomic GCF_000151885.1_Dord_2.0_genomic GCF_000164805.1_Tarsius_syrichta-2.0.1_genomic GCF_000164845.2_Vicugna_pacos-2.0.2_genomic GCF_000165445.2_Mmur_3.0_genomic GCF_000181295.1_OtoGar3_genomic GCF_000181335.3_Felis_catus_9.0_genomic GCF_000189315.1_Devil_ref_v7.0_genomic GCF_000208655.1_Dasnov3.0_genomic GCF_000223135.1_CriGri_1.0_genomic GCF_000236235.1_SpeTri2.0_genomic GCF_000281125.3_ASM28112v4_genomic GCF_000283155.1_CerSimSim1.0_genomic GCF_000292845.1_OchPri3.0_genomic GCF_000296755.1_EriEur2.0_genomic GCF_000298735.2_Oar_v4.0_genomic GCF_000313985.1_EchTel2.0_genomic GCF_000334495.1_TupChi_1.0_genomic GCF_001922835.1_NIST_Tur_tru_v1_genomic GCF_002234675.1_ASM223467v1_genomic GCF_002863925.1_EquCab3.0_genomic)

for i in ${arr[@]}
do
    sbatch nonPrimateBlastn.slurm $i
done
exit

