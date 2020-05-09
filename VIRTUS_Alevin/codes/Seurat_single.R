library(Seurat)

data.human.t <- read.table("salmon_result_human/CellvGene.txt")
data.virus.t <- read.table("salmon_result_virus/CellvGene.txt")

vimean <- apply(data.virus.t,1,mean)


merge <- merge(data.human.t,data.virus.t,by=0,all=T)
rownames(merge) <- merge$Row.names
merge <- merge[,2:ncol(merge)]
merge <- as.data.frame(t(merge))

merge[is.na(merge)] <- 0

data.merge <- CreateSeuratObject(counts = merge,project="5HPI",min.cells=5)

i <- data.merge
i@meta.data$stim <- "5hpi"
i[["percent.mt"]] <- PercentageFeatureSet(i,pattern="^MT.")
VlnPlot(i,features=c("nFeature_RNA","nCount_RNA","percent.mt"),ncol=3)

plot1 <- FeatureScatter(i,feature1="nCount_RNA",feature2 = "percent.mt")
plot2 <- FeatureScatter(i,feature1 = "nCount_RNA",feature2 = "nFeature_RNA")
plot1 + plot2

i <- subset(i,subset=nFeature_RNA>500 & nFeature_RNA < 4000 & percent.mt < 15)
i <- NormalizeData(i,normalization.method = "LogNormalize",scale.factor = 10000)

i <- FindVariableFeatures(i,selection.method = "vst",nfeatures=4000)
top10 <- head(VariableFeatures(i),10)
plot1 <- VariableFeaturePlot(i)
plot2 <- LabelPoints(plot=plot1, points=top10, repel=TRUE)
plot1 + plot2

all.genes <- rownames(i)
i <- ScaleData(i,features=all.genes)

i <- RunPCA(i,features=VariableFeatures(object=i))
print(i[["pca"]],dims=1:5,nfeatures=5)

png("pca.png",800,600)
DimPlot(i,reduction = "pca")
dev.off()

png("DimHeatMap.png",800,600)
DimHeatmap(i,dims=1:10,cells=500,balanced=TRUE)
dev.off()

i <- FindNeighbors(i,dims=1:10)
i <- FindClusters(i,resolution=0.5)

i <- RunTSNE(i,dims=1:10)

png("tsne.png",800,600)
DimPlot(i,reduction = "tsne")
dev.off()

markers <- FindAllMarkers(i,only.pos=TRUE,min.pct=0.25,logfc.threshold = 0.25)
m <- markers %>% group_by(cluster) %>% top_n(n=5,wt=avg_logFC)
write.table(m,"markers.tsv",quote=F,row.names = F,sep="\t")

saveRDS(i,file="SeuratObject.rds")