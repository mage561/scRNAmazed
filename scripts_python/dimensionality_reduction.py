#!/usr/bin/env python3
import scanpy # type: ignore
import sys

adata = scanpy.read(sys.argv[1])
adata.X = adata.layers["log1p_norm"]
scanpy.pp.pca(adata, svd_solver="arpack", use_highly_variable=True)
scanpy.tl.tsne(adata, use_rep="X_pca")
scanpy.pp.neighbors(adata)
scanpy.tl.umap(adata)

adata.write("dimensionality_reduction.h5ad")