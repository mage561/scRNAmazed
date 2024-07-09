#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { quality_control; normalization_selection_reduction } from "$params.nf_script/preprocessing.nf"
include { visualization; get_metadata as gm; get_metadata as gm2; clustering; heatmap; volcano_plot; enrichment } from "$params.nf_script/analysis.nf"
include { remove_cells } from "$params.nf_script/alteration.nf"

workflow{
    
    //Préprocessing
    qc_h5ad = quality_control(params.filtered_data, params.raw_data)
    preprocessing_h5ad = normalization_selection_reduction(qc_h5ad)

    //Analysis
    clustered_h5ad = clustering(preprocessing_h5ad)
    gm(clustered_h5ad) | view

    visualization(clustered_h5ad, channel.value('cluster_res1'))
    heatmap(clustered_h5ad, channel.value('cluster_res1'), channel.value('4')) // = nb genes
    volcano_plot(clustered_h5ad, channel.value('cluster_res1'), channel.value(['0', '4']), '10')  
    enrichment(clustered_h5ad, channel.value('cluster_res1'), channel.value(['0', '4']), '10') | view //put 'rest' on the second of .value to compare to all the others

    //Alteration
    filtered_h5ad = remove_cells(clustered_h5ad, channel.value('cluster_res1'), channel.value(['2', '1', '4']))
    gm2(filtered_h5ad) | view
}
