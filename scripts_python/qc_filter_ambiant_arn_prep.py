#!/usr/bin/env python3

import scanpy as sc # type: ignore
import sys
import pickle

sample_names = open(sys.argv[1], "r").read().splitlines()
sample_h5ad = sys.argv[2].split()
raw_h5ad = sys.argv[3].split()

list_matrices_QC = []
cells = []
genes = []
data = []
soupx_groups = []
data_tod = []

for i in range(0,len(sample_names)):
    list_matrices_QC.append(sc.read_h5ad((sample_h5ad[i])))

for i in range(0,len(sample_names)):
    cells.append(list_matrices_QC[i].obs_names)
    genes.append(list_matrices_QC[i].var_names)
    data.append(list_matrices_QC[i].X.T)
    sc.pp.normalize_per_cell(list_matrices_QC[i])
    sc.pp.log1p(list_matrices_QC[i])
    sc.pp.pca(list_matrices_QC[i])
    sc.pp.neighbors(list_matrices_QC[i])
    sc.tl.leiden(list_matrices_QC[i], key_added="soupx_groups")
    soupx_groups.append(list_matrices_QC[i].obs["soupx_groups"].astype(str).tolist())

for i in range(0,len(sample_names)):
    temp = sc.read_h5ad((raw_h5ad[i]))
    temp.var_names_make_unique()
    data_tod.append(temp.X.T)

with open('cells.pkl', 'wb') as f:
    pickle.dump(cells, f)
with open('genes.pkl', 'wb') as f:
    pickle.dump(genes, f)
with open('data.pkl', 'wb') as f:
    pickle.dump(data, f)
with open('soupx_groups.pkl', 'wb') as f:
    pickle.dump(soupx_groups, f)
with open('data_tod.pkl', 'wb') as f:
    pickle.dump(data_tod, f)