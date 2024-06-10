process getSamplePathes {
    input:
    path samplerepo

    output:
    path "sample_paths.txt"

    """
    realpath $samplerepo/* > sample_paths.txt
    """
}

process getSample5Head{
    conda 'CONDA_ENVS/r_env.yml'

    input:
    path samplePaths

    output:
    path "*.h5ad"

    """
    Rscript ${projectDir}/r_scripts/countmatrix_to_anndata.r $samplePaths
    """
}

workflow preprocessing {
    take:
    data1

    main:
    getSamplePathes(data1) | getSample5Head | view
}
