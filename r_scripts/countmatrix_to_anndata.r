samples_name <- c("D02", "D08", "D15", "D36", "D93", "Y1","D93g+","D93g-","Y1g+","Y1g-")
paths <- paste0(paste0("/mnt/wsl/docker-desktop-bind-mounts/Ubuntu/bd5066f84e888d67561e266b0594bb905f319fe6a23997bd118d205344f16f61/data/"), samples_name, "")

list_matrices <- list()
for (i in 1:length(samples_name)) {
  data <- Read10X(data.dir = paths[i])
  sample_matrix <- CreateSeuratObject(counts = data, project = samples_name[i])
  sample_matrix$time <- samples_name[i]
  sceasy::convertFormat(sample_matrix, from="seurat", to="anndata", outFile=paste0('/mnt/wsl/docker-desktop-bind-mounts/Ubuntu/bd5066f84e888d67561e266b0594bb905f319fe6a23997bd118d205344f16f61/data/',samples_name[i],'.h5ad'))
}