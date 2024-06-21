#!/usr/bin/env python3

import sys
import scanpy as sc  # type: ignore
from matplotlib import pyplot as plt # type: ignore



file_names = sys.argv[1].split(" ")
sample_names = open(sys.argv[2], "r").read().splitlines()
ercc_percent = int(sys.argv[3])

list_matrices_QC = []
list_matrices_ERCC = []

for i in range(0,len(file_names)):
    list_matrices_QC.append(sc.read_h5ad((file_names[i])))

for i in range(0,len(file_names)):
    list_matrices_QC[i].var["ERCC"] = list_matrices_QC[i].var_names.str.startswith("ERCC")
    sc.pp.calculate_qc_metrics(list_matrices_QC[i], qc_vars=["ERCC"], inplace=True, percent_top=[])
    list_matrices_QC[i].obs["outlier"] = list_matrices_QC[i].obs["pct_counts_ERCC"] > ercc_percent
    print(file_names[i]+": kept "+str(round(100*list_matrices_QC[i].obs.outlier.value_counts()[False]/len(list_matrices_QC[i])))+"% of the cells")
    list_matrices_ERCC.append(list_matrices_QC[i][(~list_matrices_QC[i].obs.outlier)])

list_ercc_genes = []
for genes in list_matrices_ERCC[0].var_names:
    if genes.upper().startswith("ERCC"):
        list_ercc_genes.append(genes)
print("Removed "+str(round(100*len(list_ercc_genes)/list_matrices_ERCC[1].n_vars, 2))+"% of the genes (ERCC)")
non_ercc_mask = ~list_matrices_ERCC[0].var_names.isin(list_ercc_genes)

for i in range(0,len(file_names)):
    list_matrices_ERCC[i] = list_matrices_ERCC[i][:, non_ercc_mask]
    list_matrices_ERCC[i].write_h5ad(sample_names[i]+".h5ad")