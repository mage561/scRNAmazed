process remove_cells{
    conda "$params.conda_envs/py_env"

    input:
    path h5ad_file
    val metadata //needs to be categorical, or we'll have to do ranges of numerics as categories
    val classes

    output:
    path '*.h5ad'

    script:
    """
    python3 $params.py_script/removal_by_metadata.py "$h5ad_file" "$metadata" "$classes" 
    """
}

process add_metadata{
    conda "$params.conda_envs/py_env"

    input:
    path h5ad_file // par exemple
    val ori_meta // "origine"
    val ori_classes //[['D02', 'D08', 'D15', 'D36', 'D93', 'Y1'], ['D93+', 'Y1+'], ['D93-', 'Y1-']]
    val new_meta // "CD43"
    val new_classes // ["Unknown", "CD43+", "CD43-"]

    output:
    path '*.h5ad'

    script:
    """
    python3 $params.py_script/add_metadata.py "$h5ad_file" "$ori_meta" "$ori_classes" "$new_meta" "$new_classes"
    """
}
