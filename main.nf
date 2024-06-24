#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { quality_control; normalization_selection_reduction } from "$params.nf_script/preprocessing.nf"

workflow{
    //Préprocessing
    qc_h5ad = quality_control(params.filtered_data, params.raw_data)
    
    //preprocessing_h5ad = normalization_selection_reduction(qc_h5ad)
    normalization_selection_reduction(qc_h5ad)

}
