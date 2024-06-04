FROM debian:bullseye-slim

LABEL image.author.name="Pitou"
LABEL image.author.email="pan-navarro@outlook.fr"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    cowsay \
    gnupg \
    ca-certificates \
    libxml2-dev \
    libcairo2-dev \
    libgit2-dev \
    software-properties-common \
    python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install R
RUN apt-key adv --no-tty --keyserver keyserver.ubuntu.com --recv-keys 'E298A3A825C0D65DFD57CBB651716619E084DAB9'
RUN add-apt-repository 'deb https://cloud.r-project.org/bin/linux/debian bullseye-cran40/'
RUN apt-get update && apt-get install -y r-base && apt-get clean

# Install R packages
RUN R -e "install.packages(c('devtools', 'remotes', 'BiocManager', 'cowplot', 'ggplot2', 'ggrepel', 'ggridges', 'igraph', 'irlba', 'leiden', 'lmtest', 'matrixStats', 'patchwork', 'plotly', 'png', 'RANN', 'RcppAnnoy', 'reticulate', 'ROCR', 'Rtsne', 'scales', 'scattermore', 'sctransform', 'spatstat.explore', 'spatstat.geom', 'uwot', 'SeuratObject', 'SoupX'), repos='https://cloud.r-project.org/')"

# Install specific version of Seurat
RUN R -e "remotes::install_version('Seurat', version = '4.4.0')"

# Install SeuratData and SeuratDisk from GitHub
RUN R -e "devtools::install_github('satijalab/seurat-data')"
RUN R -e "remotes::install_github('mojaveazure/seurat-disk')"

# Install Bioconductor packages
RUN R -e "BiocManager::install(c('scDblFinder', 'BiocParallel', 'SingleCellExperiment', 'scry', 'zellkonverter'))"

# Install additional GitHub packages
RUN R -e "devtools::install_github('cellgeni/sceasy')"

# Install Python packages
RUN pip3 install scanpy numpy seaborn scipy anndata matplotlib

# Verify installation of Python packages in R
RUN R -e "library(reticulate); py_install(c('scanpy', 'numpy', 'seaborn', 'scipy', 'anndata', 'matplotlib'))"

# Load the R libraries to ensure they're installed correctly
RUN R -e "library(SeuratObject); library(Seurat); library(SeuratData); library(SeuratDisk); library(reticulate); library(BiocParallel); library(scDblFinder); library(sceasy); library(scran); library(scry); library(zellkonverter)"

# Set PATH environment variable for cowsay
ENV PATH=$PATH:/usr/games/
