process get_metadata {
    conda "$params.conda_envs/py_env"

    input:
    path h5ad_file

    output:
    stdout

    script:
    """
    python3 $params.py_script/get_metadata.py "$h5ad_file"
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

process heatmap { //heatmap: each cluster vs all the others
    conda "$params.conda_envs/py_env"

    input:
    path h5ad_file
    val metadata
    val nb_genes


    output:
    stdout

    script:
    """
    python3 $params.py_script/heatmap.py "$h5ad_file" "$metadata" "$nb_genes" "$params.outdir"
    """
}

process volcano_plot {
    conda "$params.conda_envs/py_env"

    input:
    path h5ad_file
    val metadata //needs to be String/Bool type, not a numeric value, or we'll have to do ranges
    tuple val(class1), val(class2)

    output:
    stdout

    script:
    """
    #!/usr/bin/env python3

    import matplotlib # type: ignore
    import scanpy # type: ignore
    import numpy # type: ignore
    import sys
    import os

    matplotlib.use('Agg')

    file = "$h5ad_file" # sys.argv[1]
    
    """

}
