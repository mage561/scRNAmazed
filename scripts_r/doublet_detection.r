#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
file_names <- unlist(strsplit(args[1], " "))

set.seed(666)
for (i in 1:length(file_names)) { # nolint
    temp = zellkonverter::readH5AD(file_names[[i]])
    temp = scDblFinder::scDblFinder(temp)
    zellkonverter::writeH5AD(temp, paste0("dbl_",file_names[[i]]))
}