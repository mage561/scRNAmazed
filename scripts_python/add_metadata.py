#!/usr/bin/env python3

import scanpy as scanpy # type: ignore
import ast
import sys

adata =  scanpy.read_h5ad(sys.argv[1])
ori_meta = sys.argv[2]
ori_classes = ast.literal_eval(sys.argv[3])
new_meta = sys.argv[4]
new_classes = ast.literal_eval(sys.argv[5])

def map_ori_classes_to_new_classes(cluster):
    for idx, cluster_group in enumerate(ori_classes):
        if cluster in cluster_group:
            return new_classes[idx]
    return "Unknown"

adata.obs[new_meta] = adata.obs[ori_meta].apply(map_ori_classes_to_new_classes)

adata.write_h5ad("added_metadata.h5ad")