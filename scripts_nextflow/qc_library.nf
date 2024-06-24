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
    Rscript $params.r_script/ambiant_rna_filtering.r "$raw_data" "$filtered_data" "$names" "$params.outdir"
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
    """
}

process doublet_detection{
    conda "$params.conda_envs/r_env"

    input:
    path sample_names
    path h5ad_files

    output:
    path "*.h5ad"
    
    """
    Rscript $params.r_script/doublet_detection.r "$h5ad_files" "$sample_names" $params.outdir
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
    python3 $params.py_script/ercc_filtering.py "$h5ad_files" "$sample_names" $params.ercc_percent $params.outdir
    """
}

process concatenate_outliers_2percent  {
    conda "$params.conda_envs/py_env"

    input:
    path sample_names
    path h5ad_files

    output:
    path "quality_control.h5ad"

    script:
    """
    python3 $params.py_script/concat_outlier_2percent.py "$h5ad_files" $sample_names $params.outdir
    """
}

process normalization {
    conda "$params.conda_envs/py_env"

    input:
    path h5ad_file

    output:
    path "normalization.h5ad"

    script:
    """
    python3 $params.py_script/normalization.py "$h5ad_file"
    """
}

process feature_selection_step1 {
    conda "$params.conda_envs/r_env"

    input:
    path h5ad_file

    output:
    path "*.h5ad"

    script:
    """
    Rscript $params.r_script/feature_selection_1.r "$h5ad_file"
    """
}

process feature_selection_step2 {
    conda "$params.conda_envs/py_env"

    input:
    path h5ad_file

    output:
    path "*.h5ad"

    script:
    """
    python3 $params.py_script/feature_selection_2.py "$h5ad_file"
    """
}

process dimensionality_reduction {
    conda "$params.conda_envs/py_env"

    input:
    path h5ad_file

    output:
    path "*.h5ad"
    
    """
    python3 $params.py_script/dimensionality_reduction.py "$h5ad_file"
    """
}