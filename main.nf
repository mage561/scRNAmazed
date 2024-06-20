#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { quality_control } from "$params.nf_script/preprocessing.nf"

workflow{
    //Préprocessing
    quality_control(params.filtered_data, params.raw_data)//REMETTRE LE 2EME A raw_data
}
