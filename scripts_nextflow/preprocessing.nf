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

process correctAmbiantARN_begin {
    conda 'CONDA_ENVS/py_env.yml'

    input:
    path sample_names
    path h5ad_files
    path raw_h5ad

    output:
    path "*.pkl"

    script:
    """
    python3 $params.py_script/qc_filter_ambiant_arn_prep.py "$sample_names" "$h5ad_files" "$raw_h5ad"
    """
}

process correctAmbiantARN_end {
    input:
    path sample_names
    path h5ad_files
    path soupx_files

    output:
    stdout

    script:
    """
    #!/usr/bin/env Rscript
    filenames = unlist(strsplit("$soupx_files", ' '))

    #cells = reticulate::py_load_object(filenames[1])
    #data = reticulate::py_load_object(filenames[2])
    #data_tod = reticulate::py_load_object(filenames[3])
    #genes = reticulate::py_load_object(filenames[4])
    #soupx_groups = reticulate::py_load_object(filenames[5])
    """
}

workflow quality_control {
    take:
    filtered_data
    raw_data

    main:
    names = getNames(filtered_data)
    h5ad_raw = getRaw5Head(getRawPathes(raw_data), channel.value("raw"))

    h5ad1 = getFiltered5Head(getFilteredPathes(filtered_data), channel.value("filtered"))
    h5ad2 = filterLowQualityCells(names, h5ad1)
    
    soupx_files = correctAmbiantARN_begin(names, h5ad2, h5ad_raw)   
    correctAmbiantARN_end(names, h5ad2, soupx_files) | view
}
