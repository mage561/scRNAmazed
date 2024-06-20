include { getNames; getPathes as getRawPathes; getPathes as getFilteredPathes; get5Head as getRaw5Head; get5Head as getFiltered5Head } from "$params.nf_script/library.nf"

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

workflow quality_control {
    take:
    filtered_data
    raw_data

    main:
    names = getNames(filtered_data)
    
    h5ad1 = ambiantRnaRemoval(getRawPathes(raw_data, channel.value("raw")), getFilteredPathes(filtered_data, channel.value("filtered")), names)
    h5ad2 = filterLowQualityCells(names, h5ad1)
    
}
