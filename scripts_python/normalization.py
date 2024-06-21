#!/usr/bin/env python3

import anndata
import scanpy
import sys

file_name = sys.argv[1]

adata = scanpy.read(file_name)
scales_counts = scanpy.pp.normalize_total(adata, target_sum=None, inplace=False)
adata.layers["log1p_norm"] = scanpy.pp.log1p(scales_counts["X"], copy=True)

adata.write("normalization.h5ad")