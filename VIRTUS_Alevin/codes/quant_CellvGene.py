from vpolo.alevin import parser
alevin_df = parser.read_quants_bin(".")

alevin_df.to_csv("CellvGene.txt",sep="\t")