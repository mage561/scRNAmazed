#!/usr/bin/env python3

import os
import sys
import scanpy # type: ignore
import pandas as pd # type: ignore
import gseapy as gp # type: ignore
from gseapy.plot import gseaplot, heatmap # type: ignore

adata = scanpy.read_h5ad(sys.argv[1])
metadata = sys.argv[2]
group1 = sys.argv[3] #how is group1 differentially expressed regarding group2
group2 = sys.argv[4]
gmt_file = sys.argv[5]
output_dir = sys.argv[6]+"/analysis_plots/enrichment"


scanpy.pp.highly_variable_genes(adata, n_top_genes=4000)#, layer="counts"
scanpy.tl.rank_genes_groups(adata, metadata, reference=group2, method="t-test", key_added="t-test")#on compare tt au grp dans reference

#on chope l'expression du group=? qui est relative à celle du reference=?
t_stats = (scanpy.get.rank_genes_groups_df(adata, group=group1, key="t-test").set_index("names").loc[adata.var["highly_variable"]].sort_values("scores", key=abs, ascending=False)[["scores"]].rename_axis([f"{group1} vs {group2}"], axis=1))
t_stats.index = t_stats.index.str.upper()

results = gp.prerank(rnk=t_stats, gene_sets=gmt_file, permutation_num=100)

terms = results.res2d.Term
gseaplot(rank_metric=results.ranking, term=terms[0], ofname=f'{output_dir}/gsea_{group1}(_relative_to_{group2}).pdf', **results.results[terms[0]])