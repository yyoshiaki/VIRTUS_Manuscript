n=("SRR_uninfected.txt" "SRR_one.txt" "SRR_three.txt" "SRR_five.txt")

for i in ${n[@]}
do
    dir_name=`echo $i | rev | cut -c 5- | rev`
    mkdir $dir_name
    cd $dir_name
    for j in `cat ../$i`
    do
        prefetch $j
        cd $j
        pfastq-dump --threads 12 --split-files --outdir . -s $j.sra
        cd ..
    done
    cd ..
done
