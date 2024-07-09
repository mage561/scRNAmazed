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