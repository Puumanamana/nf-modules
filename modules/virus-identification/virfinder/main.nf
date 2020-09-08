nextflow.enable.dsl = 2

include { initOptions } from '../functions'

process VIRFINDER {
    tag {"${meta.id}"}
    label 'process_medium'
    publishDir "${params.outdir}/virfinder", mode: 'copy'
    
    container 'nakor/virfinder'

    input:
    tuple val(meta), path(fasta)
    val options

    output:
    tuple val(meta), path('virfinder_annot*.csv'), emit: all
    tuple val(meta), path("virfinder-${meta.id}.txt"), emit: ctg_ids
    
    script:
    def ioptions = initOptions(options)
    """
    #!/usr/bin/env Rscript

    source("/opt/R/virfinder.R")

    result <- parVF.pred("${fasta}", cores=$task.cpus)

    write.csv(result, 'virfinder_annot_${meta.id}.csv', quote=F)
    write(rownames(result)[result\$pvalue<${params.virfinder_thresh}], 'virfinder-${meta.id}.txt')
    """
}

workflow virfinder {
    take:
    contigs
    options
    
    main:
    VIRFINDER(contigs, options)
    
    emit:
    all = VIRFINDER.out.all
    ctg_ids = VIRFINDER.out.ctg_ids
}

workflow test {
    fasta = Channel.fromPath("$baseDir/../../test_data/sample*.fasta")
        .map{[[id: it.getSimpleName()], it]}
    virfinder(fasta, [:])
}
