#!/usr/bin/env python3
import matplotlib # type: ignore
import scanpy # type: ignore
import sys
import os

matplotlib.use('Agg')

adata = scanpy.read(sys.argv[1])
output_dir = sys.argv[2]+"/quality_control/dimension_reduction/"
os.makedirs(output_dir, exist_ok=True)

adata.X = adata.layers["log1p_norm"]
scanpy.pp.pca(adata, svd_solver="arpack", use_highly_variable=True)
scanpy.tl.tsne(adata, use_rep="X_pca")
scanpy.pp.neighbors(adata)
scanpy.tl.umap(adata)

scanpy.settings.figdir = output_dir
scanpy.pl.pca_scatter(adata, color="total_counts", save='_plot_total_counts.png')
scanpy.pl.tsne(adata, color="total_counts", save='_plot_total_counts.png')
scanpy.pl.umap(adata, color="total_counts", save='_plot_total_counts.png')

adata.write("dimensionality_reduction.h5ad")