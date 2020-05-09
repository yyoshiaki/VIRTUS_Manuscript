grep exon NC0070605.1.gff3 | cut -f 1,4,5 >  NC0070605.1.exon.bed3
sortBed -i NC0070605.1.exon.bed3 > NC0070605.1.exon.sort.bed3
bedtools merge -i NC0070605.1.exon.sort.bed3 > NC0070605.1.exon.merged.sort.bed3
awk '{SUM += $3-$2} END {print SUM}'  NC0070605.1.exon.merged.sort.bed3 # 27781
echo NC_007605.1    1    171823 > NC0070605.1.genome.bed3

mkdir coverage.exon

donors=(1 2 3)
days=(0 1 2 3 4 5 8 14)

for donor in ${donors[@]}
do
for day in ${days[@]}
do
bedtools bamtobed -i NC0070605.1_bamfiles/donor${donor}_day${day}.bam > NC0070605.1_bamfiles/donor${donor}_day${day}.bed
bedtools coverage -a NC0070605.1_bamfiles/donor${donor}_day${day}.bed -b NC0070605.1.exon.merged.sort.bed3 > coverage.exon/donor${donor}_day${day}.txt
awk '$7 > 0 {print}' coverage.exon/donor${donor}_day${day}.txt | wc -l >> exon.cov.txt
wc -l NC0070605.1_bamfiles/donor${donor}_day${day}.bed >> genome.cov.txt
done
done

bedtools subtract -a NC0070605.1.genome.bed3 -b NC0070605.1.exon.merged.sort.bed3 > NC0070605.1.nonexon.bed3
for donor in ${donors[@]}
do
for day in ${days[@]}
do
bedtools coverage -a NC0070605.1_bamfiles/donor${donor}_day${day}.bed -b NC0070605.1.nonexon.bed3 > coverage.nonexon/donor${donor}_day${day}.txt
awk '$7 > 0 {print}' coverage.nonexon/donor${donor}_day${day}.txt | wc -l >> nonexon.cov.txt
done
done
