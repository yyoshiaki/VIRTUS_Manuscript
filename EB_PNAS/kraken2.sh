kraken2-build --download-library viral --db kraken2_virus
kraken2-build --download-taxonomy --db kraken2_virus
kraken2-build --build --db kraken2_virus --threads 16

donors=(1 2 3)
days=(0 1 2 3 4 5 8 14)

for donor in ${donors[@]}
do
for day in ${days[@]}
do
kraken2 --db kraken2_virus --gzip-compressed --paired --gzip-compressed \
--report report_donor${donor}_day${day} --output output_donor${donor}_day${day} \
~/NGS_public/PRJEB31829_Blimph_EB/donor${donor}_day${day}_1.fastq.gz \
~/NGS_public/PRJEB31829_Blimph_EB/donor${donor}_day${day}_2.fastq.gz
done
done
