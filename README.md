# scRNAmazed
The goal of this pipeline is to allow biologist to easily analyze and plot their scRNAseq data
# How to Run this:
## The gitpod way
1. go to gitpod.io (> try for free > connect with whatever)
2. Click *new workspace*, then paste `https://github.com/mage561/scRNAmazed`
3. (wait for the setup to be done)
4. Upload your data in the data folder (how to format it [here](#input-data))
5. run `nextflow run main.nf`

## The local way
#### On windows
(you might need admin rights for this)
1. [install wsl](https://learn.microsoft.com/en-us/windows/wsl/install)
2. [install conda](https://docs.conda.io/projects/conda/en/latest/user-guide/install/windows.html)
3. [install nextflow](https://www.nextflow.io/docs/latest/install.html) on your wsl subsystem
4. In WSL2, Clone the following repository: `https://github.com/mage561/scRNAmazed`, get in and run the following line:
    ```shell
    conda env create --yes -f CONDA_ENVS/r_env.yml --prefix CONDA_ENVS/r_env/
    conda env create --yes -f CONDA_ENVS/py_env.yml --prefix CONDA_ENVS/py_env/
    conda env create --yes -f CONDA_ENVS/enrichment_env.yml --prefix CONDA_ENVS/enrichment_env/
    ```
    (If the installing takes forever, you can run it without the prefix and then create a symbolic link to the env repository where the prefix was supposed to be)
5. Upload your data in the data folder (how to format it [here](#input-data))
6. run `nextflow run main.nf` from the WSL2 shell
#### On Linux
Idk, I work on windows, you probably do the same as windows while skipping the wsl installing part

## Input Data:
The inside of the data folder need to follow the arborescence below.
![Arborescence du dosser data](https://drive.google.com/uc?export=download&id=1DLRRol5iM1oXHbFY02f8u14Z0bLYpTdb)<br />
You can change the names of the gray files and folder to match your sample or geneset name.<br />
An example of a working data folder is the example_data, you can run the pipeline on it using 
```shell
nextflow run main.nf --data_repo `realpath example_data/` 
```
#### Input data from Single Cell Discovery
Put in data/filtered: root/filtered_count_tables/poisson_corrected/\*<br />
Put in data/raw: root/raw_count_tables/non_poisson_corrected/\*<br />
Then zip all your barcode, feature and matrix files (ex: gzip sample1/*)<br />
If you wanna run GSEA, you will need a geneset on which to check for enrichment, please format it using the GMT file format<br />
You can check for example in the example_data repository<br />

#### Other types of input data
Put your filtered and quality controlled samples in the filtered repository<br />
Put your raw datas in the raw repository<br />
If you want to run GSEA, put your .GMT genesets on the geneset repository <br />
