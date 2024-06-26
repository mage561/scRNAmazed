#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { quality_control; normalization_selection_reduction } from "$params.nf_script/preprocessing.nf"
include { visualization; get_metadata; clustering } from "$params.nf_script/analysis.nf"

process conda_envs_setup {
    output:
    stdout

    script:
    """
    echo $params.conda_envs
    echo $params.conda.cacheDir
    """
}
process conda_envs_setup2 {
    input:
    stdin

    output:
    stdout

    script:
    """
    echo 2:
    echo $CONDA_ENVS_PATH
    """
}
workflow{
    //conda stuff
    conda_envs_setup | view

    //Préprocessing
    //qc_h5ad = quality_control(params.filtered_data, params.raw_data)
    //preprocessing_h5ad = normalization_selection_reduction(qc_h5ad)

    //Analysis
    //anal_h5ad = clustering(preprocessing_h5ad)
    //visualization(anal_h5ad, channel.value('origine'))
    //get_metadata(anal_h5ad) | view
    
}
