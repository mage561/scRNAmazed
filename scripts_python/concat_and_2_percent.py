#!/usr/bin/env python3

import sys
import anndata # type: ignore
import scanpy as sc  # type: ignore
import numpy as np # type: ignore

file_names = sys.argv[1].split(" ")

list_matrices_QC = []
for i in range(0,len(file_names)):
    list_matrices_QC.append(sc.read_h5ad((file_names[i])))

concatenated_anndata = anndata.concat(list_matrices_QC)
concatenated_anndata.obs_names_make_unique()

non_zero_per_column = np.count_nonzero(concatenated_anndata.X.A, axis=0)
print("Removed "+str(round(100*np.count_nonzero(non_zero_per_column)/list_matrices_QC[0].n_vars, 2))+"% of the genes since expr<2%")
concatenated_anndata = concatenated_anndata[:, non_zero_per_column >= concatenated_anndata.n_obs // 50]
concatenated_anndata.write("quality_control.h5ad")