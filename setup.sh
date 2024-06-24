#!/bin/bash

# Vérification de conda, de CONDA_ENVS_PATH et des environnements
if command -v conda &> /dev/null; then
    echo "Conda est installé."
    export CONDA_ENVS_PATH="`conda info --base`/envs"
    if conda env list | grep -q "r_env"; then
      echo "L'environnement Conda r_env existe."
    else
      echo "L'environnement Conda r_env n'existe pas."
      echo "Création de celui-ci"
      conda env create -f CONDA_ENVS/r_env.yml
    fi
    if conda env list | grep -q "py_env"; then
      echo "L'environnement Conda py_env existe."
    else
      echo "L'environnement Conda py_env n'existe pas."
      echo "Création de celui-ci"
      conda env create -f CONDA_ENVS/py_env.yml
    fi
else
    echo "Conda n'est pas installé. Veuillez installer Conda pour continuer."
fi
