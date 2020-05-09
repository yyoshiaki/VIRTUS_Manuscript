DATA_DIR="/mnt/d/ubuntu/bioinformatics/VIRTUS/testdata/HHV1_UNITED/data"
n=("uninfected_rep1" "uninfected_rep2" "one_rep1" "one_rep2" "three_rep1" "three_rep2" "five_rep1" "five_rep2")

mkdir results
cd results
for i in ${n[@]}
do
    mkdir $i
    cd $i
    kraken2 --db ../../kraken2_virus $DATA_DIR/$i/"$i"_2.fastq --output "$i"_output --report "$i"_report --threads 16
    cd ..
done