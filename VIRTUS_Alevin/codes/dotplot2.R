library(dplyr)
library(ggplot2)

cluster <- c("uninfected_rep1","uninfected_rep2","one_rep1","one_rep2","three_rep1","three_rep2","five_rep1","five_rep2")
label <- c("uninfected_1","uninfected_2","1hpi_1","1hpi_2","3hpi_1","3hpi_2","5hpi_1","5hpi_2")
x <- c("uninfected","1hpi","3hpi","5hpi")
r <- c(1,2)
n <- rep(c(-0.05,0.05),4)

data.virtus <- list()
for (i in cluster){
  data.virtus <- c(data.virtus,list(read.table(paste0(i,"/virus.counts.final.tsv"),header=T)[,c(1,2)]))
}
names(data.virtus) <- cluster

data.alevin <- data.frame()
for (i in cluster[3:8]){
  data.alevin <- rbind(data.alevin,sum(read.table(paste0(i,"/alevin_result_virus/CellvGene.txt"),header=T,row.names = 1)))
}
count <- c(0,0,data.alevin[[1]])
input.alevin <- data.frame(count,stim = rep(x,each=2),rep = rep(r,4),method="alevin",x=rep(1:4,each=2)-0.2+n)

merge2 <- function(dfs,...){
  base <- dfs[[1]]
  lapply(dfs[-1],function(i) base <<- merge(base,i,...))
  return(base)
}

data.virtus2 <- merge2(data.virtus,by="virus",all=T)
data.virtus2[is.na(data.virtus2)] <- 0
count <- as.numeric(data.virtus2[2,2:ncol(data.virtus2)])
input.virtus <- data.frame(count,stim = rep(x,each=2),rep = rep(r,4),method="virtus",x=rep(1:4,each=2)+0.2+n)

input <- rbind(input.alevin,input.virtus)
input$fill <- c(rep(c(1,2),4),rep(c(3,4),4))
input$stim <- factor(input$stim,levels=c("uninfected","1hpi","3hpi","5hpi"))

pdf("dotplot2.pdf",width=10,height=7)
ggplot(data = input) +
  geom_point(mapping = aes(x = x, y = count,shape=stim,color = method,group = stim),size = 4.6) +
  scale_x_continuous(breaks=c(1,2,3,4),labels = c("uninfected","1hpi","3hpi","5hpi")) +
  scale_shape_manual(values = c("circle","square","diamond","triangle")) +
  scale_color_manual(values = c("red","blue")) +
  theme_classic(base_size = 20, base_family = "Helvetica") +
  guides(fill=F,size=F) +
  labs(x="",shape="group", colour="method") 
  dev.off()
