process getSamplePathes {
    input:
    path samplerepo

    output:
    path "sample_paths.txt"

    """
    realpath $samplerepo/* > sample_paths.txt
    """
}

process getSampleNames {
    input:
    path samplerepo

    output:
    path "sample_names.txt"

    """
    ls $samplerepo > sample_names.txt
    """
}

process getSample5Head {
    conda 'CONDA_ENVS/r_env.yml'

    input:
    path samplePaths

    output:
    path "*.h5ad"

    """
    Rscript ${projectDir}/r_scripts/countmatrix_to_anndata.r $samplePaths
    """
}

process filterLowQualityCells {
    conda 'CONDA_ENVS/py_env.yml'

    output:
    stdout

    """
    #!/usr/bin/env python3
    import pickle5
    print("hellow")
    """

}

workflow quality_control {
    take:
    data1

    main:
    names = getSampleNames
    //getSamplePathes(data1) | getSample5Head | view
    filterLowQualityCells | view
}
