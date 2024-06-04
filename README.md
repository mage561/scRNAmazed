# scRNAmazed
The goal of this pipeline is to allow biologist to easily analyze their scRNAseq data
# How to Run this:
## The easy way
1. go to gitpod.io
2. in the *new workspace* field, paste `https://github.com/mage561/test_gitpod`
3. run `nextflow run main.nf -with-docker test_image`

## The local way
### On windows
(you need admin rights for this)
1. [install wsl](https://learn.microsoft.com/en-us/windows/wsl/install)
2. [install docker desktop](https://docs.docker.com/desktop/install/windows-install/#install-docker-desktop-on-windows)
3. [install nextflow](https://www.nextflow.io/docs/latest/install.html) on your wsl subsystem
4. Clone the following repository: `https://github.com/mage561/test_gitpod`
5. run Docker Desktop
6. run `nextflow run main.nf -with-docker test_image` from the wsl subsystem
### On Linux
Idk, I work on windows, will add this if I have time