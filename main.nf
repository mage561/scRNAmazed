#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { quality_control; normalization_selection_reduction } from "$params.nf_script/preprocessing.nf"
include { visualization; get_metadata as gm; get_metadata as gm2; clustering; heatmap; volcano_plot; enrichment; gsea } from "$params.nf_script/analysis.nf"
include { remove_cells; add_metadata } from "$params.nf_script/alteration.nf"

workflow{
    
    //Préprocessing
    qc_h5ad = quality_control(params.filtered_data, params.raw_data)
    preprocessing_h5ad = normalization_selection_reduction(qc_h5ad)

    //Analysis
    clustered_h5ad = clustering(preprocessing_h5ad)
    gm(clustered_h5ad) | view

    visualization(clustered_h5ad, channel.value('origine'))

    heatmap(clustered_h5ad, channel.value('cluster_res1'), channel.value('3')) // = nb genes

    volcano_plot(clustered_h5ad, channel.value('cluster_res1'), channel.value(['0', '4']), '10')  

    enrichment(clustered_h5ad, channel.value('cluster_res1'), channel.value(['0', '4']), '10') | view //put 'rest' on the second of .value to compare to all the others

    //Alteration
    altered_h5ad1 = remove_cells(clustered_h5ad, channel.value('cluster_res1'), channel.value(['7', '12', '13']))
    altered_h5ad2 = add_metadata(altered_h5ad1, channel.value("origine"), channel.value("[['D02', 'D08', 'D15', 'D36', 'D93', 'Y1'], ['D93+', 'Y1+'], ['D93-', 'Y1-']]"), channel.value("CD43"), channel.value("['Unknown', 'CD43+', 'CD43-']"))
    gm2(altered_h5ad2) | view

    //Analysis 2
    
    gsea(altered_h5ad2, channel.value('CD43'), channel.value(['CD43+', 'CD43+']), channel.value('trm3.gmt')) | view


}
