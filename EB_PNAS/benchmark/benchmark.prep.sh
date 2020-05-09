#!/bin/bash
set -xe

cd /home/yyasumizu/EB_VIRTUS
mkdir -p benchmark
cd benchmark

sambamba view -h -t 48 -f bam -F "proper_pair" /home/yyasumizu/EB_VIRTUS/donor1_day1/humanAligned.sortedByCoord.out.bam -o human.bam
bamToFastq -i human.bam -fq human.1.fq -fq2 human.2.fq

sambamba view -h -t 48 -f bam -F "proper_pair and ref_name == 'NC_007605.1'"  /home/yyasumizu/EB_VIRTUS/donor1_day1/NC_007605.1Aligned.sortedByCoord.out.bam -o subsample.NC_007605.1.bam
bamToFastq -i subsample.NC_007605.1.bam -fq NC_007605.1.1.fq -fq2 NC_007605.1.2.fq

for i in `seq 0 9`; do
echo $i
mkdir -p subsample_${i}
cd subsample_${i}
seqtk sample -s${i} ../NC_007605.1.1.fq 1000 > sub.NC_007605.1.1.fq
seqtk sample -s${i} ../NC_007605.1.2.fq 1000 > sub.NC_007605.1.2.fq
seqtk sample -s${i} ../human.1.fq 1000000 > sub.human.1.fq
seqtk sample -s${i} ../human.2.fq 1000000 > sub.human.2.fq

cat sub.NC_007605.1.1.fq sub.human.1.fq > sub.1.fq
cat sub.NC_007605.1.2.fq sub.human.2.fq > sub.2.fq

pigz sub*fq
cd ..
done
