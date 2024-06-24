#!/usr/bin/env python3

import os
import sys
import anndata # type: ignore
import scanpy as sc  # type: ignore
import numpy as np # type: ignore

file_names = sys.argv[1].split(" ")
sample_names = open(sys.argv[2], "r")
sample_names = sample_names.read().splitlines()

output_dir = sys.argv[3]+"/quality_control/"
os.makedirs(output_dir, exist_ok=True)
f = open(output_dir+"total_outlier_proportion.txt", "a")
f.write("Thus, after this quality control, we kept XX% of the cells")

list_matrices_QC = []
for i in range(0,len(file_names)):
    list_matrices_QC.append(sc.read_h5ad((file_names[i])))
    list_matrices_QC[i].obs['outlier'] = list_matrices_QC[i].obs['scDblFinder_class'] == "doublet"
    list_matrices_QC[i].obs['outlier'] = list_matrices_QC[i].obs.get('outlier', False) | (list_matrices_QC[i].obs['ercc_outlier'] == True)
    list_matrices_QC[i].obs['outlier'] = list_matrices_QC[i].obs.get('outlier', False) | (list_matrices_QC[i].obs['outlier_low_q_cell'] == True)
    f.write(sample_names[i]+": "+str(round(100*list_matrices_QC[i].obs.outlier.value_counts()[False]/len(list_matrices_QC[i])))+"%\n")


concatenated_anndata = anndata.concat(list_matrices_QC)
concatenated_anndata = concatenated_anndata[~concatenated_anndata.obs["outlier"]] # REMOVE THE OUTLIERS
concatenated_anndata.obs_names_make_unique()

non_zero_per_column = np.count_nonzero(concatenated_anndata.X.A, axis=0)

concatenated_anndata = concatenated_anndata[:, non_zero_per_column >= concatenated_anndata.n_obs // 50]
concatenated_anndata.write("quality_control.h5ad")