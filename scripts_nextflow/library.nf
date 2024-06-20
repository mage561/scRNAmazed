process getPathes {
    input:
    path samplerepo
    val suffix

    output:
    path '*.txt'

    """
    realpath $samplerepo* > sample_paths_${suffix}.txt
    """
}

process getNames {
    input:
    path samplerepo

    output:
    path "sample_names.txt"

    """
    ls $samplerepo > sample_names.txt
    """
}

process get5Head {
    input:
    path samplePaths
    val type

    output:
    path "*.h5ad"
    
    """
    Rscript $params.r_script/countmatrix_to_anndata.r $samplePaths $type
    """
}