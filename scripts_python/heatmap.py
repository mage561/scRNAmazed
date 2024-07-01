    #!/usr/bin/env python3
import matplotlib # type: ignore
import scanpy # type: ignore
import numpy # type: ignore
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

scanpy.pl.rank_genes_groups_heatmap(adata, n_genes=nb_genes, groupby=metadata,swap_axes=True,cmap="viridis",save=f'_{metadata}.png')

scanpy.pl.rank_genes_groups_dotplot(adata, n_genes=nb_genes, cmap="bwr", save=f'_{metadata}_de.png')
scanpy.pl.rank_genes_groups_dotplot(adata, n_genes=nb_genes, values_to_plot='logfoldchanges', min_logfoldchange=3, vmax=7, vmin=-7, cmap="bwr", save=f'_{metadata}_lfc.png')