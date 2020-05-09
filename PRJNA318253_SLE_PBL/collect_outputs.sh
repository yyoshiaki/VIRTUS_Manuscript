cat AccList.txt | while read line; do
mkdir -p output
cp ${line}/virus.counts.final.tsv output/${line}.tsv
done
