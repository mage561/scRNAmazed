#!/usr/bin/env python3

import os
import sys
import scanpy as sc  # type: ignore
from matplotlib import pyplot as plt # type: ignore



file_names = sys.argv[1].split(" ")
sample_names = open(sys.argv[2], "r").read().splitlines()
ercc_percent = int(sys.argv[3])

output_dir = sys.argv[4]+"/quality_control/"
os.makedirs(output_dir, exist_ok=True)
f = open(output_dir+"ercc_proportion.txt", "a")

list_matrices_QC = []
list_matrices_ERCC = []

for i in range(0,len(file_names)):
    list_matrices_QC.append(sc.read_h5ad((file_names[i])))
    list_matrices_QC[i].var["ERCC"] = list_matrices_QC[i].var_names.str.startswith("ERCC")
    sc.pp.calculate_qc_metrics(list_matrices_QC[i], qc_vars=["ERCC"], inplace=True, percent_top=[])
    list_matrices_QC[i].obs["ercc_outlier"] = list_matrices_QC[i].obs["pct_counts_ERCC"] > ercc_percent
    f.write(file_names[i]+": "+str(100-round(100*list_matrices_QC[i].obs.ercc_outlier.value_counts()[False]/len(list_matrices_QC[i])))+"% of the cells are considered ercc-contaminated\n")
    

list_ercc_genes = []
for genes in list_matrices_QC[0].var_names:
    if genes.upper().startswith("ERCC"):
        list_ercc_genes.append(genes)

non_ercc_mask = ~list_matrices_QC[0].var_names.isin(list_ercc_genes)

for i in range(0,len(file_names)):
    list_matrices_QC[i] = list_matrices_QC[i][:, non_ercc_mask]
    list_matrices_QC[i].write_h5ad(sample_names[i]+".h5ad")

f.write("\nRemoved "+str(round(100*len(list_ercc_genes)/list_matrices_QC[0].n_vars, 2))+"% of the genes (ERCC)")