library(gplots)
library(tsne)
library(pcaMethods)
library(ggplot2)
library(plyr)
library(grid)
library(pheatmap)
percent <- 0.3
CG_df <- read.table("mergeSampleMet.1000bp_2CpG.txt",header=T)
CG_df <- CG_df[,3:ncol(CG_df)]
use_Pos <- apply(CG_df,1,function(x){sum(is.na(x))<percent**ncol(CG_df)})

use_GC_Merge <- CG_df[use_Pos,]
pc <- pca(use_GC_Merge,nPcs=3,method="ppca")

imputed <- completeObs(pc)

pca<-prcomp(t(imputed))

pca_df <- as.data.frame(pca$x[,1:3])
colnames(pca_df) <- paste("PC",1:3,sep="")
#pca_df <- cbind(pca_df,Left_Samples[rownames(pca_df),])
write.table(file="GC_Merge_PCA_Result_1000bp_per0.3.txt",pca_df,quote=F,sep="\t")

tsne_input<-pca$x[,c(1:5)]
set.seed(50)
mat_tsne<-tsne(tsne_input, max_iter = 1000)
df_tsne<-data.frame(mat_tsne)
write.table(file="GC_Merge_tSNE_Result_1000bp_per0.3.txt",df_tsne,quote=F,sep="\t")

data.dist<-dist(t(use_GC_Merge))
fit <- cmdscale(data.dist, eig = TRUE, k = 2)
mds_plot<-as.data.frame( fit$points )
write.table(file="GC_Merge_MDS_Result_1000bp_per0.3.txt",mds_plot,quote=F,sep="\t")
