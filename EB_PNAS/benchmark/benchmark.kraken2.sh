#!/bin/bash
set -xe

for i in `seq 0 9`; do
echo $i
cd /home/yyasumizu/EB_VIRTUS/benchmark/subsample_${i}

kraken2 --db /home/yyasumizu/EB_VIRTUS/kraken2/kraken2_virus \
--gzip-compressed --paired \
--report kraken2_report --output kraken2_output \
/home/yyasumizu/EB_VIRTUS/benchmark/subsample_${i}/sub.1.fq.gz  \
/home/yyasumizu/EB_VIRTUS/benchmark/subsample_${i}/sub.2.fq.gz
cd ..
done
