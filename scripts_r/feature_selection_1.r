#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
file_name <- unlist(args[1])

sce <- zellkonverter::readH5AD(file_name)
sce <- scry::devianceFeatureSelection(sce, assay="X")
zellkonverter::writeH5AD(sce, "feature_selection_1.h5ad")
