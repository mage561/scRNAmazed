#!/usr/bin/env python3

import scanpy # type: ignore
import numpy # type: ignore
import sys

file_name = sys.argv[1]

adata = scanpy.read(file_name)
binomial_deviance = adata.var.binomial_deviance.T

idx = binomial_deviance.argsort()[-4000:]
mask = numpy.zeros(adata.var_names.shape, dtype=bool)
mask[idx] = True

adata.var["highly_deviant"] = mask
adata.var["binomial_deviance"] = binomial_deviance
scanpy.pp.highly_variable_genes(adata, layer="log1p_norm")

adata.write("feature_selection_2.h5ad")