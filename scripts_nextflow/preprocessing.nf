include { getNames; getPathes as getRawPathes; getPathes as getFilteredPathes; ambiantRnaRemoval; filterLowQualityCells; doublet_detection; ercc_removal; concatenate_samples_and_2_percent} from "$params.nf_script/qc_library.nf"

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
    #!/usr/bin/env python3
    import scanpy

    adata = scanpy.read("$h5ad_file")
    adata.X = adata.layers["log1p_norm"]
    scanpy.pp.pca(adata, svd_solver="arpack", use_highly_variable=True)
    scanpy.tl.tsne(adata, use_rep="X_pca")
    scanpy.pp.neighbors(adata)
    scanpy.tl.umap(adata)

    adata.write("Dimensionality_reduction.h5ad")
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
    h5ad5 = concatenate_samples_and_2_percent(h5ad4)

    emit:
    h5ad5
}

workflow normalization_selection_reduction {
    take:
    qc_h5ad

    main:
    h5ad1 = normalization(qc_h5ad)
    h5ad2 = feature_selection_step1(h5ad1) | feature_selection_step2
    h5ad3 = dimensionality_reduction(h5ad2)
    h5ad3 | view

    emit:
    h5ad3
}