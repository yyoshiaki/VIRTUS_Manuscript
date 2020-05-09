fasterq-dump -e 12 -p --split-files SRR10903401
fasterq-dump -e 12 -p --split-files SRR10903402

pigz *.fastq

mkdir SRR10903401
cd SRR10903401

cwltool --tmp-outdir-prefix=/home/yyasumizu/tmp_cwl/ \
--tmpdir-prefix=/home/yyasumizu/tmp_cwl/ \
~/Programs/VIRTUS/workflow/VIRTUS.PE.cwl \
--fastq1 ~/NGS_public/PRJNA601736_BALF_sarscov2/SRR10903401_1.fastq.gz \
--fastq2 ~/NGS_public/PRJNA601736_BALF_sarscov2/SRR10903401_2.fastq.gz \
--genomeDir_human ~/reference/200315_VIRTUS/STAR_index_human \
--genomeDir_virus ~/reference/200315_VIRTUS/STAR_index_virus \
--salmon_index_human ~/reference/200315_VIRTUS/salmon_index_human \
--salmon_quantdir_human salmon_human \
--outFileNamePrefix_human human --nthreads 40

cd ..

mkdir SRR10903402
cd SRR10903402

cwltool --tmp-outdir-prefix=/home/yyasumizu/tmp_cwl/ \
--tmpdir-prefix=/home/yyasumizu/tmp_cwl/ \
~/Programs/VIRTUS/workflow/VIRTUS.PE.cwl \
--fastq1 ~/NGS_public/PRJNA601736_BALF_sarscov2/SRR10903402_1.fastq.gz \
--fastq2 ~/NGS_public/PRJNA601736_BALF_sarscov2/SRR10903402_2.fastq.gz \
--genomeDir_human ~/reference/200315_VIRTUS/STAR_index_human \
--genomeDir_virus ~/reference/200315_VIRTUS/STAR_index_virus \
--salmon_index_human ~/reference/200315_VIRTUS/salmon_index_human \
--salmon_quantdir_human salmon_human \
--outFileNamePrefix_human human --nthreads 40

cd ..

hisat2-build NC_045512.2.fasta HISAT2_index_NC_045512.2.fasta
hisat2 -x HISAT2_index_NC_045512.2.fasta -1 SRR10903401/unmapped_1.fq -2 SRR10903401/unmapped_2.fq -S hisat2_SRR10903401_NC_045512.2.sam
samtools sort hisat2_SRR10903401_NC_045512.2.sam -@ 12 -O BAM > hisat2_SRR10903401_NC_045512.2.sort.bam
samtools index hisat2_SRR10903401_NC_045512.2.sort.bam

hisat2-build NC_045512.2.fasta HISAT2_index_NC_045512.2.fasta
hisat2 -x HISAT2_index_NC_045512.2.fasta -1 SRR10903402/unmapped_1.fq -2 SRR10903402/unmapped_2.fq -S hisat2_SRR10903402_NC_045512.2.sam
samtools sort hisat2_SRR10903402_NC_045512.2.sam -@ 12 -O BAM > hisat2_SRR10903402_NC_045512.2.sort.bam
samtools index hisat2_SRR10903402_NC_045512.2.sort.bam
