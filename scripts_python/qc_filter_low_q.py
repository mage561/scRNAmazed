#!/usr/bin/env python3
import matplotlib # type: ignore
import scanpy as sc # type: ignore
import numpy as np # type: ignore
import os
import sys

matplotlib.use('Agg')
from matplotlib import pyplot as plt # type: ignore
from scipy.stats import median_abs_deviation # type: ignore

output_dir_pre = sys.argv[4]+"/quality_control/pre_MAD/"
output_dir_post = sys.argv[4]+"/quality_control/post_MAD/"
os.makedirs(output_dir_pre, exist_ok=True)
os.makedirs(output_dir_post, exist_ok=True)

file_sample_names = open(sys.argv[1], "r")
sample_names = file_sample_names.read().splitlines()
sample_h5ad = (sys.argv[2]).split()
specie=sys.argv[3]
mad_treshold=int(sys.argv[5])
mt_pc_treshold=int(sys.argv[6])

list_matrices_QC = []

def is_outlier(data, metric: str, nmads: int):#automatic thresholding via MAD (median absolute deviation)
    M = data.obs[metric]
    outlier = (M < np.median(M) - nmads * median_abs_deviation(M)) | (np.median(M) + nmads * median_abs_deviation(M) < M)
    return outlier

for i in range(0,len(sample_names)):
    list_matrices_QC.append(sc.read_h5ad((sample_h5ad[i])))
    list_matrices_QC[i].var[specie] = list_matrices_QC[i].var_names.str.startswith(specie+"-")
    sc.pp.calculate_qc_metrics(list_matrices_QC[i], qc_vars=[specie], inplace=True, percent_top=[], log1p=True)

for i in range(0,len(sample_names)):
    p=sc.pl.violin(list_matrices_QC[i],keys=["log1p_total_counts", "log1p_n_genes_by_counts", "pct_counts_mt"], show=False)
    p.set_title(sample_names[i]+"_PRE_MAD")
    plt.savefig(os.path.join(output_dir_pre, f"{sample_names[i]}_PRE_MAD.png"))
    plt.close()

for i in range(0, len(list_matrices_QC)):#Similar to [Germain et al., 2020], we mark cells as outliers if they differ by 5 MADs (relatively permissive filtering)
    list_matrices_QC[i].obs["outlier_low_q_cell"] = (
        is_outlier(list_matrices_QC[i], "log1p_total_counts", mad_treshold) 
        | is_outlier(list_matrices_QC[i], "log1p_n_genes_by_counts", mad_treshold) 
        | is_outlier(list_matrices_QC[i], "pct_counts_mt", mad_treshold) 
        | (list_matrices_QC[i].obs["pct_counts_mt"] > mt_pc_treshold)
        )

for i in range(0,len(sample_names)):
    p=sc.pl.violin(list_matrices_QC[i][(~list_matrices_QC[i].obs.outlier_low_q_cell)],keys=["log1p_total_counts", "log1p_n_genes_by_counts", "pct_counts_mt"], show=False)
    p.set_title(sample_names[i]+"_POST_MAD")
    plt.savefig(os.path.join(output_dir_post, f"{sample_names[i]}_POST_MAD.png"))
    plt.close()
    list_matrices_QC[i].write_h5ad("./filtered_"+sample_names[i]+".h5ad")
