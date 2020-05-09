cat AccList.txt | while read line; do
 fasterq-dump $line -O ./ -e 12 -p
 pigz -p 40 ${line}_1.fastq
 pigz -p 40 ${line}_2.fastq
done
