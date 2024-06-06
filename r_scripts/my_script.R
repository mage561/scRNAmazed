library(Seurat)

# Exemple de création d'un objet Seurat avec des données simulées
data <- matrix(rnorm(2000), nrow = 200, ncol = 10)
seurat_object <- CreateSeuratObject(counts = data)

# Afficher le résumé de l'objet Seurat
print(seurat_object)