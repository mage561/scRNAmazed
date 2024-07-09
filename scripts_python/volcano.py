#!/usr/bin/env python3

import os
import sys
import numpy # type: ignore
import scanpy # type: ignore
import pandas # type: ignore
import matplotlib # type: ignore
from adjustText import adjust_text # type: ignore
from matplotlib import pyplot as plt # type: ignore

matplotlib.use('Agg')

adata = scanpy.read_h5ad(sys.argv[1])
metadata = sys.argv[2]
group1 = sys.argv[3]
group2 = sys.argv[4]
nb_genes = int(sys.argv[5])
output_dir = sys.argv[6]+"/analysis_plots/volcano/"

os.makedirs(output_dir, exist_ok=True)
scanpy.settings.figdir = output_dir

if isinstance(adata.obs[metadata][0], numpy.bool_):
    adata.obs[metadata] = adata.obs[metadata].astype(str).astype('category')

scanpy.tl.rank_genes_groups(adata, metadata, groups=[group1], reference=group2)

minus_log10_pvals = -numpy.log10(adata.uns['rank_genes_groups']['pvals_adj'][group1])
logfoldchanges = adata.uns['rank_genes_groups']['logfoldchanges'][group1]

dataframe = pandas.DataFrame({'-log10pval': minus_log10_pvals, 'logfoldchanges': logfoldchanges, 'gene': adata.uns['rank_genes_groups']['names'][group1], 'score': adata.uns['rank_genes_groups']['scores'][group1]})
significant = (dataframe['-log10pval'] > -numpy.log10(0.01)) & (abs(dataframe['logfoldchanges']) > 1.5)

top_genes = dataframe[significant].sort_values(by=['score','-log10pval','logfoldchanges'], key=lambda v: abs(v), ascending=[False, False, False])

top_genes.to_csv(os.path.join(output_dir, f"{metadata}_volcano_{group1}_vs_{group2}.csv"), index=False)

plt.close()
plt.figure(figsize=(10, 6))
plt.title('Volcano Plot')
plt.xlabel('Log2 Fold Change')
plt.ylabel('-Log10 p-value')
plt.scatter(dataframe['logfoldchanges'], dataframe['-log10pval'], c='grey', s=1)
plt.scatter(dataframe[significant]['logfoldchanges'], dataframe[significant]['-log10pval'], c='red', s=1)
texts = []
for i, row in top_genes.head(nb_genes).iterrows():
    texts.append(plt.text(row['logfoldchanges'], row['-log10pval'], row['gene'], fontsize=10))
adjust_text(texts)
plt.savefig(os.path.join(output_dir, f"{metadata}_volcano_{group1}_vs_{group2}.pdf"))