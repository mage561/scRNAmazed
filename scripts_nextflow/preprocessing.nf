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
    path "*.h5ad"
    
    """
    python3 $params.py_script/qc_filter_low_q.py "$sample_names" "$h5ad_files" "$params.specie" "$params.outdir"
    """
}

workflow quality_control {
    take:
    filtered_data
    raw_data

    main:
    names = getSampleNames(filtered_data)
    h5ad1 = getSamplePathes(filtered_data) | getSample5Head
    h5ad2 = filterLowQualityCells(names, h5ad1)
    
}
