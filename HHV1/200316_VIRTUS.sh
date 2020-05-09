#!/bin/bash
set -xe

cat AccList.txt | while read line; do
 mkdir -p ${line}
 cd ${line}

 cwltool --tmp-outdir-prefix=/home/yyasumizu/tmp_cwl/ \
 --tmpdir-prefix=/home/yyasumizu/tmp_cwl/ \
 ~/Programs/VIRTUS/workflow/VIRTUS.SE.cwl \
 --fastq ~/NGS_public/GSE123782_HHV1_scRNAseq/${line}_2.fastq.gz \
 --genomeDir_human ~/reference/200315_VIRTUS/STAR_index_human \
 --genomeDir_virus ~/reference/200315_VIRTUS/STAR_index_virus \
 --salmon_index_human ~/reference/200315_VIRTUS/salmon_index_human \
 --salmon_quantdir_human salmon_human \
 --outFileNamePrefix_human human --nthreads 40

 cd ..
done
