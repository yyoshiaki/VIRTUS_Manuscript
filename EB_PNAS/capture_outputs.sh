#!/bin/bash
set -xe

donors=(1 2 3)
days=(0 1 2 3 4 5 8 14)

for donor in ${donors[@]}
do
 for day in ${days[@]}
  do
   sample=donor${donor}_day${day}
   echo $sample
   mkdir -p $sample
   cd $sample
   
   cwltool --tmp-outdir-prefix=/home/yyasumizu/tmp_cwl/ \
   --tmpdir-prefix=/home/yyasumizu/tmp_cwl/ \
   ~/Programs/VIRTUS/workflow/VIRTUS.PE.cwl \
   --fastq1 /home/yyasumizu/NGS_public/PRJEB31829_Blimph_EB/${sample}_1.fastq.gz \
   --fastq2 /home/yyasumizu/NGS_public/PRJEB31829_Blimph_EB/${sample}_2.fastq.gz \
   --genomeDir_human ~/reference/200315_VIRTUS/STAR_index_human \
   --genomeDir_virus ~/reference/200315_VIRTUS/STAR_index_virus \
   --salmon_index_human ~/reference/200315_VIRTUS/salmon_index_human \
   --salmon_quantdir_human salmon_human \
   --outFileNamePrefix_human human --nthreads 40

   cwltool --tmp-outdir-prefix=/home/yyasumizu/tmp_cwl/ \
   --tmpdir-prefix=/home/yyasumizu/tmp_cwl/ \
   ~/Programs/VIRTUS/workflow/VIRTUS.PE.singlevirus.cwl \
   --fq1_unmapped ./unmapped_1.fq \
   --fq2_unmapped ./unmapped_2.fq \
   --genomeDir_singlevirus ~/reference/200315_VIRTUS/STAR_index_NC_007605.1 \
   --salmon_index_singlevirus ~/reference/200315_VIRTUS/salmon_index_NC_007605.1 \
   --outFileNamePrefix_star NC_007605.1 \
   --quantdir salmon_NC_007605.1 \
   --runThreadN 40

   cd ..
  done
done
