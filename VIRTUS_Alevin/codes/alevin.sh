SCRIPT_DIR=$(cd $(dirname $0); pwd)

n=("uninfected_rep1" "uninfected_rep2" "one_rep1" "one_rep2" "three_rep1" "three_rep2" "five_rep1" "five_rep2")

for i in ${n[@]}
do
    cd $i
    salmon alevin -l A -1 "$i"_1.fastq -2 "$i"_2.fastq --dropseq -i ~/bioinformatics/VIRTUS/index/salmon_index_HHV1/ -p 12 -o alevin_result_virus --tgMap ~/bioinformatics/VIRTUS/index/txp2gene_HHV1.tsv
    cd alevin_result_virus
    python3 $SCRIPT_DIR/quant_CellvGene.py
    cd ../..
done