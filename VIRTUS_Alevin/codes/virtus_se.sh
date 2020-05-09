SCRIPT_DIR=$(cd $(dirname $0); pwd)
DATA_DIR="/mnt/d/ubuntu/bioinformatics/VIRTUS/testdata/HHV1_Alevin/rawdata"

n=("uninfected_rep1" "uninfected_rep2" "one_rep1" "one_rep2" "three_rep1" "three_rep2" "five_rep1" "five_rep2")

for i in ${n[@]}
do
    mkdir $i
    cd $i
        rm -rf /tmp/*
        ~/bioinformatics/VIRTUS/workflow/VIRTUS.SE.cwl --fastq $DATA_DIR/$i/"$i"_2.fastq --genomeDir_human ~/bioinformatics/VIRTUS/index/STAR_index_human/ --genomeDir_virus ~/bioinformatics/VIRTUS/index/STAR_index_virus --salmon_index_human ~/bioinformatics/VIRTUS/index/salmon_index_human --salmon_quantdir_human salmon_quant_human --outFileNamePrefix_human human --nthreads 40
    cd ..
done