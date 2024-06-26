#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { quality_control; normalization_selection_reduction } from "$params.nf_script/preprocessing.nf"
include { visualization; get_metadata; clustering } from "$params.nf_script/analysis.nf"

workflow{
    
    //Préprocessing
    qc_h5ad = quality_control(params.filtered_data, params.raw_data)
    preprocessing_h5ad = normalization_selection_reduction(qc_h5ad)

    //Analysis
    anal_h5ad = clustering(preprocessing_h5ad)
    visualization(anal_h5ad, channel.value('origine'))
    get_metadata(anal_h5ad) | view
    
}
