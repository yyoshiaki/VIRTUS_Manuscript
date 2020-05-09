wget http://hgdownload.soe.ucsc.edu/admin/exe/macOSX.x86_64/
chmod 777 gff3ToGenePred
wget http://hgdownload.soe.ucsc.edu/admin/exe/macOSX.x86_64/genePredToBed
chmod 777 genePredToBed

./gff3ToGenePred NC0070605.1.gff3 NC0070605.1.genePred
./genePredToBed NC0070605.1.genePred NC0070605.1.bed