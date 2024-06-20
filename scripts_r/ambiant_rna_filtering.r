#!/usr/bin/env Rscript
library("celda")

args <- commandArgs(trailingOnly = TRUE)

raw_pathes <- readLines(args[1])
filtered_pathes <- readLines(args[2])
sample_names <- readLines(args[3])

for (i in 1:length(sample_names)) { # nolint
    counts <- Seurat::Read10X(paste0(filtered_pathes, "/", sample_names[[i]])) # nolint
    counts.raw <- Seurat::Read10X(paste0(raw_pathes, "/", sample_names[[i]]))# nolint
    sce <- SingleCellExperiment::SingleCellExperiment(list(counts = counts))
    sce.raw <- SingleCellExperiment::SingleCellExperiment(list(counts = counts.raw))# nolint
    sce <- decontX::decontX(sce, background = sce.raw)
    assay(sce, "counts") <- round(decontX::decontXcounts(sce))
    zellkonverter::writeH5AD(sce, paste0(sample_names[[i]],'.h5ad'))# nolint
}