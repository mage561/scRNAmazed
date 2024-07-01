#!/usr/bin/env Rscript
library("celda")

args <- commandArgs(trailingOnly = TRUE)

raw_pathes <- readLines(args[1])
filtered_pathes <- readLines(args[2])
sample_names <- readLines(args[3])
outdir <- args[4]

subdir <- file.path(outdir, "/quality_control/ambiant_rna/")
if (!dir.exists(subdir)) {
  dir.create(subdir, recursive = TRUE)
}

for (i in 1:length(sample_names)) { # nolint
    counts <- Seurat::Read10X(paste0(filtered_pathes, '/', sample_names[[i]])) # nolint
    counts.raw <- Seurat::Read10X(paste0(raw_pathes, '/', sample_names[[i]]))# nolint
    sce <- SingleCellExperiment::SingleCellExperiment(list(counts = counts))
    sce.raw <- SingleCellExperiment::SingleCellExperiment(list(counts = counts.raw))# nolint
    sce <- decontX::decontX(sce, background = sce.raw)
    contam_plot <- decontX::plotDecontXContamination(sce)
    ggplot2::ggsave(filename = paste0(subdir, sample_names[[i]], "_ambiant_rna.pdf"), plot = contam_plot, width = 6, height = 4, dpi = 300) # nolint
    assay(sce, "counts") <- round(decontX::decontXcounts(sce), 2)
    zellkonverter::writeH5AD(sce, paste0(sample_names[[i]],'.h5ad'))# nolint
}