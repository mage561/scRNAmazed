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
    python3 $params.py_script/clustering.py "$h5ad_file" "$params.outdir"
    """
}

process differential_expression {
    conda "$params.conda_envs/py_env"

    input:
    path h5ad_file
    val metadata
    val nb_genes


    output:
    //path '*.h5ad'
    stdout

    script:
    """
    python3 $params.py_script/differential_expression.py "$h5ad_file" "$metadata" "$nb_genes" "$params.outdir"
    """
}