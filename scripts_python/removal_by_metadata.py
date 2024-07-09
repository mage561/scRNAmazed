#!/usr/bin/env python3

import sys
import ast
import scanpy # type: ignore

adata = scanpy.read_h5ad(sys.argv[1])
metadata = sys.argv[2]
groups = list(map(str, ast.literal_eval(sys.argv[3])))

adata = adata[~adata.obs[metadata].isin(groups)]

adata.write_h5ad("filtered.h5ad")