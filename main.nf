#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { preprocessing } from './nextflow_scripts/preprocessing.nf'

params.datapath = "$PWD/data/"
params.execpath = "$PWD/exec_files/"

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
    echo $params.datapath
    """
}

process test2 {
    conda 'CONDA_ENVS/r_env.yml'

    output:
    stdout

    script:
    """
    #!/usr/bin/env Rscript
    library(Seurat)
    library(sceasy)
    print("Hellowwww")
    """
}


workflow{
    preprocessing(params.datapath)
    //cowSaysHi() | view
    //test | view
    //numbers = randomNum()
    
}
