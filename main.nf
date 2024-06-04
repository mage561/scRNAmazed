#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { preprocessing } from './nextflow_scripts/preprocessing.nf'

params.datapath = "$PWD/data/"

process cowSaysHi {
    output:
    stdout

    script:
    """
    cowsay `The End.`
    """
}

workflow{
    preprocessing(params.datapath)
    //cowSaysHi() | view
}
