include { getNames; getPathes as getRawPathes; getPathes as getFilteredPathes; ambiantRnaRemoval; filterLowQualityCells; doublet_detection; ercc_removal; concatenate_outliers_2percent; normalization; feature_selection_step1; feature_selection_step2; dimensionality_reduction} from "$params.nf_script/qc_library.nf"

workflow quality_control {
    take:
    filtered_data
    raw_data

    main:
    names = getNames(filtered_data)
    
    h5ad1 = ambiantRnaRemoval(getRawPathes(raw_data, channel.value("raw")), getFilteredPathes(filtered_data, channel.value("filtered")), names)
    h5ad2 = filterLowQualityCells(names, h5ad1)
    h5ad3 = doublet_detection(names, h5ad2)
    h5ad4 = ercc_removal(names, h5ad3)
    h5ad5 = concatenate_outliers_2percent(names, h5ad4)
    
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
    h5ad3

    emit:
    h5ad3
}