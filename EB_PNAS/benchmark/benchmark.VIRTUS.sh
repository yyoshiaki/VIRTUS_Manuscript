#!/bin/bash
set -xe

for i in `seq 0 9`; do
echo $i
cd /home/yyasumizu/EB_VIRTUS/benchmark/subsample_${i}

cwltool --tmp-outdir-prefix=/home/yyasumizu/tmp_cwl/ \
--tmpdir-prefix=/home/yyasumizu/tmp_cwl/ \
~/Programs/VIRTUS/workflow/VIRTUS.PE.cwl \
--fastq1 /home/yyasumizu/EB_VIRTUS/benchmark/subsample_${i}/sub.1.fq.gz \
--fastq2 /home/yyasumizu/EB_VIRTUS/benchmark/subsample_${i}/sub.2.fq.gz \
--genomeDir_human ~/reference/200315_VIRTUS/STAR_index_human \
--genomeDir_virus ~/reference/200315_VIRTUS/STAR_index_virus \
--salmon_index_human ~/reference/200315_VIRTUS/salmon_index_human \
--salmon_quantdir_human salmon_human \
--outFileNamePrefix_human human --nthreads 40
cd ..
done
