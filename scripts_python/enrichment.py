#!/usr/bin/env python3

import os
import sys
import numpy # type: ignore
import pandas # type: ignore
import scanpy # type: ignore
import decoupler # type: ignore
import matplotlib # type: ignore
from matplotlib import pyplot as plt # type: ignore

matplotlib.use('Agg')

adata = scanpy.read_h5ad(sys.argv[1])
metadata = sys.argv[2]
group1 = sys.argv[3]
group2 = sys.argv[4]
nb_pathway = int(sys.argv[5])
output_dir = sys.argv[6]+"/analysis_plots/enrichment/"

os.makedirs(output_dir, exist_ok=True)
scanpy.settings.figdir = output_dir

if isinstance(adata.obs[metadata][0], numpy.bool_):
    adata.obs[metadata] = adata.obs[metadata].astype(str).astype('category')

scanpy.pp.highly_variable_genes(adata, n_top_genes=4000)#, layer="counts"
scanpy.tl.rank_genes_groups(adata, metadata, reference=group2, method="t-test", key_added="t-test")#on compare tout au groupe2 et on stocke ça dans ['t-test']

msigdb = decoupler.get_resource("MSigDB")
reactome = msigdb.query("collection == 'reactome_pathways'")
reactome = reactome[~reactome.duplicated(("geneset", "genesymbol"))]

geneset_size = reactome.groupby("geneset", observed=False).size()
gsea_genesets = geneset_size.index[(geneset_size > 15) & (geneset_size < 500)] # on vire les geneset tout petit ou trop gros

t_stats = (scanpy.get.rank_genes_groups_df(adata, group1, key="t-test").set_index("names").loc[adata.var["highly_variable"]].sort_values("scores", key=abs, ascending=False)[["scores"]].rename_axis([f"Cluster {group1} vs {group2}"], axis=1))
t_stats.index = t_stats.index.str.upper()
scores, norm, pvals = decoupler.run_gsea(t_stats.T,reactome[reactome["geneset"].isin(gsea_genesets)],source="geneset",target="genesymbol",)
gsea_results = (pandas.concat({"score": scores.T, "norm": norm.T, "pvals": pvals.T}, axis=1).droplevel(level=1, axis=1).sort_values("pvals"))
gsea_results = gsea_results.sort_values(by=['pvals', 'norm'], ascending=[True, False], key=lambda v: abs(v))
gsea_results.to_csv(os.path.join(output_dir, f"{metadata}_enrichment_{group1}_vs_{group2}.csv"))
