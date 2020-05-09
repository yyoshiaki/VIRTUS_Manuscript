library(dplyr)
library(ggplot2)

cluster <- c("uninfected_rep1","uninfected_rep2","one_rep1","one_rep2","three_rep1","three_rep2","five_rep1","five_rep2")
label <- c("uninfected_1","uninfected_2","1hpi_1","1hpi_2","3hpi_1","3hpi_2","5hpi_1","5hpi_2")


data <- list()
for (i in cluster){
  data <- c(data,list(read.table(paste0(i,"/virus.counts.final.tsv"),header=T)[,c(1,2)]))
}
names(data) <- cluster

merge2 <- function(dfs,...){
  base <- dfs[[1]]
  lapply(dfs[-1],function(i) base <<- merge(base,i,...))
  return(base)
}


data2 <- merge2(data,by="virus",all=T)
data2[is.na(data2)] <- 0
rownames(data2) <- data2[,1]
data2 <- data2[2,2:ncol(data2)]
rep1 <- as.numeric(data2[1,c(1,3,5,7)])
rep2 <- as.numeric(data2[1,c(2,4,6,8)])

data3 <- data.frame(rep1,rep2)
x <- c(1,2,3,4)
par(family="NotoSans CJK JP Mono")

pdf("dot.pdf",width=10,height=6)
options(scipen=0)
plot(x=x-0.05,y=data3[,1],xlim=c(1,4),xaxp=c(1,4,3),ylim=c(0,7000000),yaxp=c(0,7000000,7),xlab="",ylab="",xaxt="n",pch=1,cex=1.7)
axis(1,at=x,labels=c("uninfected","1hpi","3hpi","5hpi"),cex.axis=1.2)
par(new=T)
plot(x=x+0.05,y=data3[,2],xlim=c(1,4),ylim=c(1,7000000),xlab="",ylab="",xaxt="n",yaxt="n",pch=2,cex=1.7)
dev.off()


