#!/usr/bin/env python3
import matplotlib # type: ignore
import scanpy # type: ignore
import sys
import os

matplotlib.use('Agg')

adata = scanpy.read(sys.argv[1])
output_dir = sys.argv[2]+"/quality_control/dimension_reduction/"
os.makedirs(output_dir, exist_ok=True)

adata.var["highly_variable"] = adata.var["highly_deviant"]

scanpy.pp.neighbors(adata, n_pcs=30)
scanpy.pp.pca(adata, svd_solver="arpack", use_highly_variable=True)
scanpy.tl.tsne(adata, use_rep="X_pca")
scanpy.pp.neighbors(adata)
scanpy.tl.umap(adata)

scanpy.settings.figdir = output_dir
scanpy.pl.pca_scatter(adata, color="total_counts", save='_plot_total_counts.png')
scanpy.pl.tsne(adata, color="total_counts", save='_plot_total_counts.png')
scanpy.pl.umap(adata, color="total_counts", save='_plot_total_counts.png')

#retirer les informations inutiles:
del adata.layers['decontXcounts']
#adata.obs = adata.obs.drop(columns=['decontX_contamination', 'decontX_clusters', 'n_genes_by_counts', 'log1p_n_genes_by_counts', 'log1p_total_counts', 'total_counts_mt', 'log1p_total_counts_mt', 'outlier_low_q_cell', 'scDblFinder_class', 'total_counts_ERCC', 'log1p_total_counts_ERCC', 'ercc_outlier', 'outlier'])
adata.obs = adata.obs.drop(columns=['decontX_clusters', 'outlier_low_q_cell', 'scDblFinder_class', 'ercc_outlier', 'outlier','decontX_contamination', 'n_genes_by_counts', 'log1p_n_genes_by_counts', 'log1p_total_counts', 'total_counts_mt', 'log1p_total_counts_mt', 'pct_counts_mt', 'scDblFinder_score', 'total_counts_ERCC', 'log1p_total_counts_ERCC', 'pct_counts_ERCC'])
adata.write("dimensionality_reduction.h5ad")