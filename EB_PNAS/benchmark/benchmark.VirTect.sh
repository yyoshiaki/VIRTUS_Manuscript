#!/bin/bash
set -xe

for i in `seq 0 9`; do
echo $i
cd /home/yyasumizu/EB_VIRTUS/benchmark/subsample_${i}
mkdir -p VirTect

python2 ~/Programs/VirTect/VirTect.py -t 12 \
-1 /home/yyasumizu/EB_VIRTUS/benchmark/subsample_${i}/sub.1.fq.gz \
-2 /home/yyasumizu/EB_VIRTUS/benchmark/subsample_${i}/sub.2.fq.gz \
-o VirTect \
-ucsc_gene ~/Programs/VirTect/human_reference/gencode.v29.annotation.gtf  \
-index ~/Programs/VirTect/human_reference/GRCh38.p12.genome \
-index_vir ~/Programs/VirTect/viruses_reference/viruses_757.fasta -d 200

cd ..
done
