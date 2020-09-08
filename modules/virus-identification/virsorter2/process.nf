include { initOptions } from './functions'

process DL_VIRSORTER2_DB {
    publishDir params.dbdir, mode: 'copy'
    container 'nakor/virsorter'

    output:
    path 'virsorter2_db'

    script:
    """
    virsorter setup -d virsorter2_db -j $task.cpus
    """    
}

process VIRSORTER2 {
    tag {"${meta.id}"}
    publishDir params.outdir+"/virsorter2", mode: "copy"
    publishDir params.outdir, mode: "copy", pattern: "virsorter2_contigs*.txt"
    container 'nakor/virsorter'

    input:
    tuple val(meta), path(fasta)
    path vs2_db
    val options

    output:
    tuple val(meta), path('final-viral-score.tsv'), emit: all
    tuple val(meta), path ("virsorter2-${meta.id}.txt"), emit: ctg_ids
    
    script:
    def ioptions = initOptions(options)
    """
    #!/usr/bin/env bash

    virsorter run $ioptions.args  -w out -i $fasta -j $task.cpus -d $vs2_db
    mv out/final-viral-score.tsv .
    tail -n+2 final-viral-score.tsv | cut -f1 | cut -d'|' -f1 > virsorter2-${meta.id}.txt
    """
}
