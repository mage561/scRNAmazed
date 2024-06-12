process getPathes {
    input:
    path samplerepo

    output:
    path "sample_paths.txt"

    """
    realpath $samplerepo/* > sample_paths.txt
    """
}

process getNames {
    input:
    path samplerepo

    output:
    path "sample_names.txt"

    """
    ls $samplerepo > sample_names.txt
    """
}

process get5Head {
    conda 'CONDA_ENVS/r_env.yml'

    input:
    path samplePaths
    val type

    output:
    path "*.h5ad"

    """
    Rscript $params.r_script/countmatrix_to_anndata.r $samplePaths $type
    """
}