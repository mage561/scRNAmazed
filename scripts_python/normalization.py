#!/usr/bin/env python3

import os
import sys
import scanpy # type: ignore
import seaborn # type: ignore
import matplotlib # type: ignore

from matplotlib import pyplot # type: ignore
matplotlib.use('Agg')

file_name = sys.argv[1]
output_dir = sys.argv[2]+"/quality_control/"
os.makedirs(output_dir, exist_ok=True)

adata = scanpy.read(file_name)
scales_counts = scanpy.pp.normalize_total(adata, target_sum=None, inplace=False)
adata.layers["log1p_norm"] = scanpy.pp.log1p(scales_counts["X"], copy=True)

fig, axes = pyplot.subplots(1, 2, figsize=(10, 5))
p1 = seaborn.histplot(adata.obs["total_counts"], bins=100, kde=False, ax=axes[0])
axes[0].set_title("Total counts")
p2 = seaborn.histplot(adata.layers["log1p_norm"].sum(1), bins=100, kde=False, ax=axes[1])
axes[1].set_title("Shifted logarithm")
pyplot.savefig(os.path.join(output_dir, "Normalisation.png"))
pyplot.close()


adata.write("normalization.h5ad")