git clone https://github.com/DerrickWood/kraken2.git
cd kraken2
mkdir install

bash install_kraken2.sh install

cd install
sudo cp ./kraken2{,-build,-inspect} /bin
mkdir kraken2_virus

kraken2-build --download-library viral --db kraken2_virus
kraken2-build --download-taxonomy --db kraken2_virus
kraken2-build --build --db kraken2_virus --threads 16