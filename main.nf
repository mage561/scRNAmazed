#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { preprocessing } from './nextflow_scripts/preprocessing.nf'

params.datapath = "$PWD/data/"
params.execpath = "$PWD/exec_files"
params.test= "$PWD/my_script.R"

process cowSaysHi {
    output:
    stdout

    script:
    """
    cowsay Hi
    """
}

process test {
    conda 'CONDA_ENVS/test_np.yml'

    output:
    stdout

    script:
    """
    #!/usr/bin/env python3
    import numpy
    print(numpy.cos(0))
    """
}
workflow{
    //preprocessing(params.datapath)
    //cowSaysHi() | view
    test | view
}
