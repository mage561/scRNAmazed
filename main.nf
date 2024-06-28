#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { quality_control; normalization_selection_reduction } from "$params.nf_script/preprocessing.nf"
include { visualization; get_metadata; clustering; differential_expression } from "$params.nf_script/analysis.nf"

workflow{
    
    //Préprocessing
    qc_h5ad = quality_control(params.filtered_data, params.raw_data)
    preprocessing_h5ad = normalization_selection_reduction(qc_h5ad)

    //Analysis
    clustered_h5ad = clustering(preprocessing_h5ad)

    differential_expression(clustered_h5ad, channel.value('clustering_leiden_res1'), channel.value('3')) | view
    visualization(clustered_h5ad, channel.value('clustering_leiden_res1'))
    get_metadata(clustered_h5ad) | view
    
}
