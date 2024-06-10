#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { quality_control } from './nextflow_scripts/preprocessing.nf'

params.datapath = "$PWD/data/"
params.outdir = "$PWD/output/"
params.specie = "mt"//mt for mouse, MT for Human

workflow{
    //Préprocessing
    quality_control(params.datapath)

}
