library(Seurat)
library(ggplot2)
library(cowplot)
library(stringr)

theme_set(theme_cowplot())
group.name <- c("uninfected_rep1","uninfected_rep2","one_rep1","one_rep2","three_rep1","three_rep2","five_rep1","five_rep2")
stim.list <- c("uninfected","one","three","five")
rep.list <- c("rep1","rep2")
viral.gene.set <- read.table("../../../index/txp2gene_HHV1.tsv")[,2]

#CellvGene.txtのパスで読み込み
for (i in group.name){
  path <- paste0(i,"/alevin_result_human/CellvGene.txt")
  assign(paste0(i,"_human"),read.table(path))
}

for (i in group.name[3:length(group.name)]){
  path <- paste0(i,"/alevin_result_virus/CellvGene.txt")
  assign(paste0(i,"_virus"),read.table(path))
}

#infectedではhumanとvirusのテーブルをmerge
for (i in 3:8){
  eval(parse(text=paste0(
    group.name[i],"_merge","<-","merge(",group.name[i],"_human,",group.name[i],"_virus,by=0, all=T)"
  )))
  eval(parse(text=paste0(
    group.name[i],"_merge","[is.na(",group.name[i],"_merge)]","<- 0"
  )))
}

uninfected.name <- paste0(group.name[c(1,2)],"_human")
f <- ls()
infected.name <- f[grep("merge",f)]
remove(f)

#input_nameにテーブル名のリスト、namesに群分け入れる
input_name <- c(uninfected.name,infected.name)

#input_nameからテーブルのリストを作る
eval(parse(text=paste0(
  "input.list <- list(",str_c(input_name,collapse=","),")"  
)))

#転置
input.list.t <- list()
for (i in input.list){
  input.list.t <- c(input.list.t,list(as.data.frame(t(i))))
}
remove(input.list)

#CreateSeuratObject
seurat.list <- list()
for (i in 1:length(input.list.t)){
  seurat.list <- c(seurat.list, list(CreateSeuratObject(counts = input.list.t[[i]],project=input_name[i],min.cells=5)))
  seurat.list[[i]]$group <- input_name[i]
  seurat.list[[i]]$stim <- rep(stim.list,each=2)[i]
  seurat.list[[i]]$group <- rep(rep.list,4)[i]
}
names(seurat.list) <- input_name

preprocessing <- function(x){
  x[["percent.mt"]] <- PercentageFeatureSet(x,pattern="^MT.")
  x <- NormalizeData(x,normalization.method = "LogNormalize",scale.factor = 10000)
  x <- FindVariableFeatures(x,selection.method = "vst",nfeatures=4000)
  all.genes <- rownames(x)
  x <- ScaleData(x,features=all.genes)
  return(x)
}

seurat.list <- lapply(seurat.list,preprocessing)

anchors <- FindIntegrationAnchors(object.list = seurat.list,dims=1:30)
integrated <- IntegrateData(anchorset = anchors,dims=1:30, normalization.method = "LogNormalize")

integrated <- ScaleData(integrated,verbose=F)
integrated <- RunPCA(integrated,npcs=30,verbose=F)
integrated <- RunUMAP(integrated,dims=1:30)
p1 <- DimPlot(integrated,reduction="umap",group.by="group",pt.size = 1)
p2 <- DimPlot(integrated,reduction="umap",group.by="stim",pt.size = 1)
p1+p2

theme_set(theme_cowplot())
Idents(integrated) <- "stim"
avg.integrated <- log1p(AverageExpression(integrated,verbose=F)$RNA)
avg.integrated$gene <- rownames(avg.integrated)

p1 <- ggplot(avg.integrated,aes(uninfected,five)) + geom_point() 
p1 <- LabelPoints(plot=p1,points=rownames(markers))
p1
