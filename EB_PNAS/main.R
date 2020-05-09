library(tidyverse)
library(dplyr)
library(grid)
library(gridExtra)
library(ggpubr)
library(tximport)
library(DESeq2)
library(pheatmap)
library(viridis)

donors <- c(1,2,3)
days <- c(0,1,2,3,4,5,8,14)
samples <- character(length(donors)*length(days))
i <- 0
for (donor in donors){
  for (day in days) {
    i <- i + 1
    samples[i] <- paste("donor", donor, "_day", day, sep = "")
  }
}

df.stats <- read_table('stats.txt')
df.stats <- df.stats %>%
  mutate(sample = str_extract(file, pattern = "donor._day\\d*")) %>%
  drop_na(sample) %>%
  group_by(sample) %>%
  summarise(num_seqs = mean(num_seqs), avg_len = mean(avg_len)) %>%
  mutate(layout = 'PE')
head(df.stats)

i <- 1
for (sample in samples) {
  if (i == 1) {
    tb.virus.count <- read_delim(paste('output/', sample, '/virus.counts.final.tsv', sep = ""), delim="\t", col_names = c("virus", "hit", "rate"), skip = 1) %>%
      mutate(hit = str_extract(hit, pattern = "\\d+")) %>%
      type_convert() %>%
      dplyr::rename(!!sample := hit) %>%
      select(-rate)
  }  else {
    t <- read_delim(paste('output/', sample, '/virus.counts.final.tsv', sep = ""), delim="\t", col_names = c("virus", "hit", "rate"), skip = 1) %>%
      mutate(hit = str_extract(hit, pattern = "\\d+")) %>%
      type_convert() %>%
      dplyr::rename(!!sample := hit) %>%
      select(-rate)
    tb.virus.count <- full_join(tb.virus.count, t)
  }
  i <- 2
}

i <- 1
for (sample in samples) {
  if (i == 1) {
    tb.virus.percent <- read_delim(paste('output/', sample, '/virus.counts.final.tsv', sep = ""), delim="\t", col_names = c("virus", "hit", "rate"), skip = 1) %>%
      mutate(hit = str_extract(hit, pattern = "\\d+")) %>%
      type_convert() %>%
      mutate(percent = rate * 100) %>% 
      dplyr::rename(!!sample := percent) %>%
      select(-c(hit, rate))
  }  else {
    t <- read_delim(paste('output/', sample, '/virus.counts.final.tsv', sep = ""), delim="\t", col_names = c("virus", "hit", "rate"), skip = 1) %>%
      mutate(hit = str_extract(hit, pattern = "\\d+")) %>%
      type_convert() %>%
      mutate(percent = rate * 100) %>% 
      dplyr::rename(!!sample := percent) %>%
      select(-c(hit, rate))
    tb.virus.percent <- full_join(tb.virus.percent, t)
  }
  i <- 2
}

# sort
tb.virus.count <- tb.virus.count[append(c("virus"), samples)]
tb.virus.count <- tb.virus.count %>%
  filter(virus != '*') %>%
  arrange(desc(donor1_day1))

tb.virus.percent <- tb.virus.percent[append(c("virus"), samples)]
tb.virus.percent <- tb.virus.percent %>%
  filter(virus != '*') %>%
  arrange(desc(donor1_day1))

write_csv(tb.virus.percent, 'virus.percent.csv')
write_csv(tb.virus.count, 'virus.count.csv')


tb.virus.percent <- tb.virus.percent %>% 
  gather(key = sample, value = percent, samples) %>% 
  mutate(donor = str_extract(sample, pattern = "donor\\d"), day = str_extract(sample, pattern = "\\d*$")) %>% 
  type_convert()


p1 <- tb.virus.percent %>% 
  filter(virus == "NC_007605.1_Human_herpesvirus_4_complete_wild_type_genome") %>% 
  ggplot(aes(x = day, y = percent, color = donor, group = donor)) +
  geom_line() + 
  # theme(legend.position = "none") + 
  labs(title = "EBV", y = "% virus reads / human reads")

p2 <- tb.virus.percent %>% 
  filter(virus == "NC_001716.2_Human_herpesvirus_7,_complete_genome") %>% 
  ggplot(aes(x = day, y = percent, color = donor, group = donor)) +
  geom_line() + 
  # theme(legend.position = "none") + 
  labs(title = "HHV7", y = "% virus reads / human reads")

p3 <- tb.virus.percent %>% 
  filter(virus == "NC_022518.1_Human_endogenous_retrovirus_K113_complete_genome") %>% 
  ggplot(aes(x = day, y = percent, color = donor, group = donor)) +
  geom_line() + 
  # theme(legend.position = "none") + 
  labs(title = "ERV K113", y = "% virus reads / human reads")

ggarrange(p1, p2, p3, nrow = 1, legend = "bottom")

### EBV genes

tx2knownGene <- read_delim('NC_007605.1.tx2gene.txt', '\t', col_names = c('TXNAME', 'GENEID'))
files <- paste(c("output/"), samples, c("/salmon_NC_007605.1/quant.sf"), sep='')
names(files) <- samples
txi.salmon <- tximport(files, type = "salmon", tx2gene = tx2knownGene, countsFromAbundance="no") # use count because gene expression itself differs a lot
head(txi.salmon$counts)
write.table(txi.salmon$counts, 'NC0070605.1.counts.tsv')

tb.sample <- df.stats %>% 
  mutate(donor = str_extract(sample, pattern = "donor\\d"), day = str_extract(sample, pattern = "\\d*$")) %>% 
  type_convert()

df.sample <- as_data_frame(tb.sample)
df.sample <- df.sample[match(samples, df.sample$sample),]

dds <- DESeqDataSetFromTximport(txi.salmon,
                                   colData = df.sample,
                                   design = ~ day)
colData(dds)
dds <- DESeq(dds)
res <- results(dds, alpha = 0.1)
summary(res)

resSig <- res[which(res$padj < 0.1 ), ]
resSig

ntd <- normTransform(dds)

# vsd <- vst(dds, nsub=nrow(dds))
plotPCA(ntd, intgroup=c("donor", "day"))
pcaData <- plotPCA(ntd, intgroup=c("donor", "day"), returnData=TRUE)
percentVar <- round(100 * attr(pcaData, "percentVar"))
ggplot(pcaData, aes(PC1, PC2, color=day, shape=donor)) +
  geom_point(size=3) +
  xlab(paste0("PC1: ",percentVar[1],"% variance")) +
  ylab(paste0("PC2: ",percentVar[2],"% variance")) + 
  coord_fixed()

# select <- order(rowMeans(counts(dds,normalized=TRUE)),
#                 decreasing=TRUE)[1:20]
select <- head(order(res$padj),20)
df <- as.data.frame(colData(dds)[,c("donor","day")])
df <- df[order(df$day, df$donor),]
pheatmap(assay(ntd)[select,row.names(df)], cluster_rows=TRUE, show_rownames=TRUE,
         cluster_cols=FALSE, annotation_col=df, 
         color = viridis(50), main = "variance top 20 genes", filename = "img/EBV_DEGtop20.pdf")

pheatmap(assay(ntd)[row.names(resSig),row.names(df)], cluster_rows=TRUE, show_rownames=TRUE,
         cluster_cols=FALSE, annotation_col=df, 
         color = viridis(50), main = "significant genes", filename = "img/EBV_siggenes_0.1.pdf")

pheatmap(assay(ntd)[,row.names(df)], cluster_rows=TRUE, show_rownames=TRUE,
         cluster_cols=FALSE, annotation_col=df, 
         border_color = NA, color = viridis(50), main = "all genes", filename = "img/EBV_allgenes.pdf", cellheight = 8)

