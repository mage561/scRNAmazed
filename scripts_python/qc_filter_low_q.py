#!/usr/bin/env python3
import matplotlib
import scanpy as sc
import numpy as np
import os
import sys

matplotlib.use('Agg')
from matplotlib import pyplot as plt
from scipy.stats import median_abs_deviation

output_dir = "$params.outdir/quality_control/"
os.makedirs(output_dir, exist_ok=True)

file_sample_names = open(sys.argv[1], "r")
sample_names = file_sample_names.read().splitlines()
sample_h5ad = (sys.argv[2]).split()
list_matrices_QC = []

for i in range(0,len(sample_names)):
    list_matrices_QC.append(sc.read_h5ad((sample_h5ad[i])))
    list_matrices_QC[i].var["mt"] = list_matrices_QC[i].var_names.str.startswith("mt-")
    sc.pp.calculate_qc_metrics(list_matrices_QC[i], qc_vars=["mt"], inplace=True, percent_top=[], log1p=True)

def is_outlier(data, metric: str, nmads: int):#automatic thresholding via MAD
    M = data.obs[metric]
    outlier = (M < np.median(M) - nmads * median_abs_deviation(M)) | (np.median(M) + nmads * median_abs_deviation(M) < M)
    return outlier
for i in range(0,len(sample_names)):
    p=sc.pl.violin(list_matrices_QC[i],keys=["log1p_total_counts", "log1p_n_genes_by_counts", "pct_counts_mt"], show=False)
    p.set_title(sample_names[i]+"_PRE_MAD")
    plt.savefig(os.path.join(output_dir, f"{sample_names[i]}_PRE_MAD.png"))
    plt.close()
for i in range(0, len(list_matrices_QC)):
    list_matrices_QC[i].obs["outlier"] = (
        is_outlier(list_matrices_QC[i], "log1p_total_counts", 5) 
        | is_outlier(list_matrices_QC[i], "log1p_n_genes_by_counts", 5) 
        | is_outlier(list_matrices_QC[i], "pct_counts_mt", 3) 
        | (list_matrices_QC[i].obs["pct_counts_mt"] > 10)
        )
    print(sample_names[i]+": "+str(round(100*list_matrices_QC[i].obs.outlier.value_counts()[False]/len(list_matrices_QC[i])))+"%")
    raw_matrices = list_matrices_QC
    list_matrices_QC[i] = list_matrices_QC[i][(~list_matrices_QC[i].obs.outlier)]
for i in range(1,len(sample_names)):
    p=sc.pl.violin(list_matrices_QC[i],keys=["log1p_total_counts", "log1p_n_genes_by_counts", "pct_counts_mt"], show=False)
    p.set_title(sample_names[i]+"_POST_MAD")
    plt.savefig(os.path.join(output_dir, f"{sample_names[i]}_POST_MAD.png"))
    plt.close()