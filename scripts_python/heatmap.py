    #!/usr/bin/env python3
import matplotlib # type: ignore
import scanpy # type: ignore
import numpy # type: ignore
import pandas # type: ignore
import sys
import os

matplotlib.use('Agg')

file = sys.argv[1]
metadata = str(sys.argv[2])
nb_genes = int(sys.argv[3])
output_dir = sys.argv[4]+"/analysis_plots/heatmaps/"

os.makedirs(output_dir, exist_ok=True)
scanpy.settings.figdir = output_dir

adata = scanpy.read(file)

if isinstance(adata.obs[metadata][0], numpy.bool_):
    adata.obs[metadata] = adata.obs[metadata].astype(str).astype('category')

marker_genes_dict = {}
scanpy.tl.rank_genes_groups(adata, metadata, method='wilcoxon')
for cluster in adata.obs[metadata].cat.categories:
    marker_genes_dict[cluster] = adata.uns['rank_genes_groups']['names'][cluster][:nb_genes].tolist()

scanpy.pl.rank_genes_groups_heatmap(adata, n_genes=nb_genes, groupby=metadata, save=f'_{metadata}.pdf')
scanpy.pl.rank_genes_groups_dotplot(adata, n_genes=nb_genes, cmap="bwr", save=f'_{metadata}_de.pdf')
scanpy.pl.rank_genes_groups_dotplot(adata, n_genes=nb_genes, values_to_plot='logfoldchanges', min_logfoldchange=3, vmax=7, vmin=-7, cmap="bwr", save=f'{metadata}_lfc.pdf')

names = adata.uns['rank_genes_groups']['names']
score = adata.uns['rank_genes_groups']['scores']
pvals_adj = adata.uns['rank_genes_groups']['pvals_adj']
logfoldchanges = adata.uns['rank_genes_groups']['logfoldchanges']

data = []
groups = names.dtype.names
for group in groups:
    for gene_idx in range(len(names[group])):
        data.append({
            'group': group,
            'gene': names[group][gene_idx],
            'score':score[group][gene_idx],
            '-log10pval': -numpy.log10(pvals_adj[group][gene_idx] + 1e-300),# to avoid log(0)
            'logfoldchange': logfoldchanges[group][gene_idx]
        })
df = pandas.DataFrame(data)

df_filtered = df[(df['-log10pval'] > -numpy.log10(0.01)) & (abs(df['logfoldchange']) > 1.5)]
df_filtered = df_filtered[['group', 'gene', 'score', 'logfoldchange', '-log10pval']]

df_filtered.to_csv(os.path.join(output_dir, f"{metadata}_heatmap.csv"), index=False)