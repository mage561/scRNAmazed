process getPathes {
    input:
    path samplerepo
    val suffix

    output:
    path '*.txt'

    """
    realpath $samplerepo* > sample_paths_${suffix}.txt
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
    input:
    path samplePaths
    val type

    output:
    path "*.h5ad"
    
    """
    Rscript $params.r_script/countmatrix_to_anndata.r $samplePaths $type
    """
}


process ambiantRnaRemoval {
    conda "$params.conda_envs/r_env"

    input:
    path raw_data
    path filtered_data
    path names

    output:
    path '*.h5ad'

    script:
    """
    Rscript $params.r_script/ambiant_rna_filtering.r "$raw_data" "$filtered_data" "$names"
    """
}

process filterLowQualityCells {
    conda "$params.conda_envs/py_env"

    input:
    path sample_names
    path h5ad_files

    output:
    path "*.h5ad"
    
    """
    python3 $params.py_script/qc_filter_low_q.py "$sample_names" "$h5ad_files" $params.specie $params.outdir $params.MAD $params.mt_percent 
    echo ooo
    """
}

process doublet_detection{
    conda "$params.conda_envs/r_env"

    input:
    path h5ad_files

    output:
    path "*.h5ad"
    
    """
    Rscript $params.r_script/doublet_detection.r "$h5ad_files" 
    """
}

process ercc_removal{
    conda "$params.conda_envs/py_env"

    input:
    path sample_names
    path h5ad_files

    output:
    path "*.h5ad"

    script:
    """
    python3 $params.py_script/ercc_filtering.py "$h5ad_files" "$sample_names" $params.ercc_percent 
    """
}

process concatenate_samples_and_2_percent  {
    conda "$params.conda_envs/py_env"

    input:
    path h5ad_files

    output:
    path "quality_control.h5ad"

    script:
    """
    python3 $params.py_script/concat_and_2_percent.py "$h5ad_files"
    """
}