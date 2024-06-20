include { getNames; getPathes as getRawPathes; getPathes as getFilteredPathes} from "$params.nf_script/library.nf"

process ambiantRnaRemoval {
    //conda 'CONDA_ENVS/r_env.yml'
    conda '/root/miniconda3/envs/r_env'

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
    conda 'CONDA_ENVS/py_env.yml'

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
    //conda 'CONDA_ENVS/r_env.yml'
    conda '/root/miniconda3/envs/r_env'

    input:
    path h5ad_files

    output:
    path "*.h5ad"
    
    """
    Rscript $params.r_script/doublet_detection.r "$h5ad_files" 
    """
}

process ercc_removal{
    conda 'CONDA_ENVS/py_env.yml'

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
    conda 'CONDA_ENVS/py_env.yml'

    input:
    path h5ad_files

    output:
    path "quality_control.h5ad"

    script:
    """
    python3 $params.py_script/concat_and_2_percent.py "$h5ad_files"
    """
}
workflow quality_control {
    take:
    filtered_data
    raw_data

    main:
    names = getNames(filtered_data)
    
    h5ad1 = ambiantRnaRemoval(getRawPathes(raw_data, channel.value("raw")), getFilteredPathes(filtered_data, channel.value("filtered")), names)
    h5ad2 = filterLowQualityCells(names, h5ad1)
    h5ad3 = doublet_detection(h5ad2)
    h5ad4 = ercc_removal(names, h5ad3)
    concatenate_samples_and_2_percent(h5ad4) | view
}
