process getSamplePathes {
    input:
    path samplerepo

    output:
    path "sample_paths.txt"

    """
    realpath $samplerepo/* > sample_paths.txt
    """
}

process getSampleNames {
    input:
    path samplerepo

    output:
    path "sample_names.txt"

    """
    ls $samplerepo > sample_names.txt
    """
}

process getSample5Head {
    conda 'CONDA_ENVS/r_env.yml'

    input:
    path samplePaths

    output:
    path "*.h5ad"

    """
    Rscript $params.r_script/countmatrix_to_anndata.r $samplePaths
    """
}

process filterLowQualityCells {
    conda 'CONDA_ENVS/py_env.yml'

    input:
    path sample_names
    path h5ad_files

    output:
    stdout

    """
    python3 $params.py_script/qc_filter_low_q.py "$sample_names" "$h5ad_files"
    """

}

workflow quality_control {
    take:
    data1

    main:
    names = getSampleNames(data1)
    h5ad = getSamplePathes(data1) | getSample5Head
    filterLowQualityCells(names, h5ad) | view
    
}
