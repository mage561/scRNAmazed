process visualization {
    conda "$params.conda_envs/py_env"

    input:
    path h5ad_file
    val metadata

    output:
    stdout

    script:
    """
    python3 $params.py_script/visualization.py "$h5ad_file" "$metadata" "$params.outdir"
    """
}

process get_metadata {
    conda "$params.conda_envs/py_env"

    input:
    path h5ad_file

    output:
    stdout

    script:
    """
    #!/usr/bin/env python3
    import scanpy

    adata = scanpy.read("$h5ad_file")
    print("Available metadata are the following:")
    for elem in adata.obs.columns:
        print("\t"+elem)
    """
}

process clustering {
    conda "$params.conda_envs/py_env"

    input:
    path h5ad_file

    output:
    path '*.h5ad'

    script:
    """
    #!/usr/bin/env python3

    import matplotlib # type: ignore
    import scanpy

    adata = scanpy.read("$h5ad_file")
    output_dir = "$params.outdir"+"/analysis_plots/"

    matplotlib.use('Agg')
    scanpy.settings.figdir = output_dir

    scanpy.pp.neighbors(adata, n_pcs=30) #les 30 composante principales sont suffisante pour capturer la variabilité
    #scanpy.tl.umap(adata)
    scanpy.tl.leiden(adata, key_added="leiden_res0_25", resolution=0.25)
    scanpy.tl.leiden(adata, key_added="leiden_res0_5", resolution=0.5)
    scanpy.tl.leiden(adata, key_added="leiden_res1", resolution=1.0)

    adata.write_h5ad("clustered.h5ad")
    """
}