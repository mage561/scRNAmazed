#!/usr/bin/env python3
import scanpy  # type: ignore
import sys

adata = scanpy.read(sys.argv[1])

print("Available metadata are the following:")
for elem in adata.obs.columns:
    if adata.obs[elem].dtype.name == "category":
        print(f"\t{elem}: categories - {adata.obs[elem].dtype.categories.to_list()}")
    else:
        print(f"\t{elem}: {adata.obs[elem].dtype.name}")