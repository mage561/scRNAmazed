#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
file_names <- unlist(strsplit(args[1], " "))
sample_names <- readLines(args[2])
outdir <- paste0(args[3], "quality_control/")

if (!dir.exists(outdir)) {
  dir.create(outdir, recursive = TRUE)
}

set.seed(666)
for (i in 1:length(file_names)) { # nolint
  temp <- anndata::read_h5ad(file_names[[i]])
  print(class(temp$X))
  temp2 <- scDblFinder::scDblFinder(SingleCellExperiment::SingleCellExperiment(list(counts = BiocGenerics::t(temp$X)))) # nolint
  temp$obs["scDblFinder_score"] <- temp2$scDblFinder.score
  temp$obs["scDblFinder_class"] <- temp2$scDblFinder.class

  prop_table <- round(table(temp2$scDblFinder.class) / length(temp2$scDblFinder.class),2) # nolint
  result_df <- data.frame(sample_name = sample_names[[i]], proportion = prop_table) # nolint
  write.table(result_df,paste0(outdir,"doublet_proportion.txt"), sep = "\t", row.names = FALSE, quote = FALSE,col.names = FALSE, append = TRUE) # nolint

  anndata::write_h5ad(temp, paste0("dbl_", file_names[[i]]))
}