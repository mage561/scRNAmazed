# scRNAmazed
The goal of this pipeline is to allow biologist to easily analyze and plot their scRNAseq data
# How to Run this:
## The easy way
1. go to gitpod.io
2. in the *new workspace* field, paste `https://github.com/mage561/test_gitpod`
3. run `nextflow run main.nf`

## The local way
### On windows
(you might need admin rights for this)
1. [install wsl](https://learn.microsoft.com/en-us/windows/wsl/install)
2. [install conda](https://docs.conda.io/projects/conda/en/latest/user-guide/install/windows.html)
3. [install nextflow](https://www.nextflow.io/docs/latest/install.html) on your wsl subsystem
4. Clone the following repository: `https://github.com/mage561/test_gitpod`, get in and run the following line:
    ```shell
    source setup.sh
    ```
6. run `nextflow run main.nf` from the wsl subsystem
### On Linux
Idk, I work on windows, will add this if I have time

##Input Data:
A directory for each sample containing the matrix.mtx, genes.tsv (or features.tsv), and barcodes.tsv (all .gz) files provided by 10X (filteredCountTable Directory, \[non-corrected?\])
According to the article i'm following, you better use the filtered_count_table+poisson-corrected as input, tho we will need the unfiltered non-poisson later