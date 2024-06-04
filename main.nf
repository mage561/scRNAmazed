#!/usr/bin/env nextflow

include { sayBye as bye; preprocessing as preproc } from './nextflow_scripts/preprocessing.nf'

process cowSaysHi {
    output:
    stdout

    script:
    """
    cowsay Hi
    """
}

workflow preprocessing {
    preproc()
    bye | view
}

workflow{
    preprocessing()
    cowSaysHi() | view
}
