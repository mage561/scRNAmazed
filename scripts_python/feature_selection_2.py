#!/usr/bin/env python3
import matplotlib # type: ignore
import seaborn # type: ignore
import scanpy # type: ignore
import numpy # type: ignore
import sys
import os

from matplotlib import pyplot # type: ignore
matplotlib.use('Agg')

file_name = sys.argv[1]
output_dir = sys.argv[2]+"/quality_control/"
os.makedirs(output_dir, exist_ok=True)

adata = scanpy.read(file_name)
binomial_deviance = adata.var.binomial_deviance.T

idx = binomial_deviance.argsort()[-4000:]
mask = numpy.zeros(adata.var_names.shape, dtype=bool)
mask[idx] = True

adata.var["highly_deviant"] = mask
adata.var["binomial_deviance"] = binomial_deviance
scanpy.pp.highly_variable_genes(adata)

ax = seaborn.scatterplot(data=adata.var, x="means expression", y="dispersions", hue="highly_deviant", s=5)
ax.set_xlim(None, 1.5)
ax.set_ylim(None, 3)
pyplot.savefig(os.path.join(output_dir, "Feature_Selection.pdf"))
pyplot.close()


adata.write("feature_selection_2.h5ad")