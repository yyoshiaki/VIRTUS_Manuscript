library(dplyr)
library(gplots)
library(viridisLite)

cluster <- c("uninfected_rep1","uninfected_rep2","one_rep1","one_rep2","three_rep1","three_rep2","five_rep1","five_rep2")
col.label <- c("uninfected_1","uninfected_2","1hpi_1","1hpi_2","3hpi_1","3hpi_2","5hpi_1","5hpi_2")
row.label <- c("NC_001798.1\n_Human_herpesvirus_2,\n_complete_genome","NC_001806.1\n_Human_herpesvirus_1,\n_complete_genome","NC_022518.1\n_Human_endogenous_retrovirus_K113\n_complete_genome")

data <- list()
for (i in cluster){
  data <- c(data,list(read.table(paste0(i,"/virus.counts.final.tsv"),header=T)[,c(1,3)]))
}
names(data) <- cluster

merge2 <- function(dfs,...){
  base <- dfs[[1]]
  lapply(dfs[-1],function(i) base <<- merge(base,i,...))
  return(base)
}

data2 <- merge2(data,by="virus",all=T)
data2[is.na(data2)] <- 0
data2 <- log(data2[,2:ncol(data2)])
data2[data2==-Inf] <- NA
colnames(data2) <- col.label
rownames(data2) <- row.label

pdf("Heatmap.pdf",width=10,height=7)
heatmap(as.matrix(data2),Colv = NA,margin=c(20,15),col=greenred(75),Rowv = NA,cexRow = 1.5,cexCol = 1.5,labRow=row.label)
dev.off()

pdf("Heatmap2.pdf",width=10,height=7)
par(cex.main=1, cex.lab=0.7, cex.axis=0.7)
heatmap.2(as.matrix(data2),trace = "none",dendrogram = "none",scale="none",cexCol = 1.5,cexRow = 1.5,col = viridis(1000),lwid = c(1,6),lhei = c(1,4),margins = c(10,25),na.color="black",Colv=F,Rowv = F,key.title = "",key.xlab = "",key.ylab = "",symm=F,symkey=F,symbreaks=F)
dev.off()

