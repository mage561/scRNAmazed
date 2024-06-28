#!/usr/bin/env python3

import matplotlib # type: ignore
import scanpy # type: ignore
import sys

adata = scanpy.read(sys.argv[1])
output_dir = sys.argv[2]+"/analysis_plots/"

matplotlib.use('Agg')
scanpy.settings.figdir = output_dir

#scanpy.pp.neighbors(adata, n_pcs=30) #les 30 composante principales sont suffisante pour capturer la variabilité
#scanpy.tl.umap(adata)
#scanpy.tl.leiden(adata, key_added="cluster_res0_25", resolution=0.25)
#scanpy.tl.leiden(adata, key_added="cluster_res0_5", resolution=0.5)
scanpy.tl.leiden(adata, key_added="cluster_res1", resolution=1.0)

adata.write_h5ad("clustered.h5ad")