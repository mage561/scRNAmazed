args <- commandArgs(trailingOnly = TRUE)

paths <- readLines(args[1])
samples_name <- basename(paths)
type <- args[2]

list_matrices <- list()
for (i in 1:length(samples_name)) { # nolint
  data <- Seurat::Read10X(data.dir = paths[i])
  sample_matrix <- Seurat::CreateSeuratObject(counts = data, project = samples_name[i])# nolint
  sample_matrix$time <- samples_name[i]
  sceasy::convertFormat(sample_matrix, from="seurat", to="anndata", outFile=paste0(samples_name[i],'_',type,'.h5ad')) # nolint
}