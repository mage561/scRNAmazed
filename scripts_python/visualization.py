#!/usr/bin/env python3

import matplotlib # type: ignore
import scanpy # type: ignore
import numpy # type: ignore
import sys
import os

matplotlib.use('Agg')

file = sys.argv[1]
metadata = str(sys.argv[2])
output_dir = sys.argv[3]+"/analysis_plots/"

os.makedirs(output_dir, exist_ok=True)
scanpy.settings.figdir = output_dir

adata = scanpy.read(file)

if isinstance(adata.obs[metadata][0], numpy.bool_):
    adata.obs[metadata] = adata.obs[metadata].astype(str).astype('category')

scanpy.pp.neighbors(adata, n_pcs=30)
scanpy.pl.pca_scatter(adata, color=metadata, save=f'_plot_{metadata}.png')
scanpy.pl.tsne(adata, color=metadata, save=f'_plot_{metadata}.png')
scanpy.pl.umap(adata, color=metadata, save=f'_plot_{metadata}.png')