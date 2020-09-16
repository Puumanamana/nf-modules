include { initOptions; saveFiles ; getSoftwareName } from './functions'


process VIRSORTER2_RUN {
    tag {"${meta.id}"}
    label 'process_medium'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:options, publish_dir:getSoftwareName(task.process), publish_id:"") }
    container 'nakor/virsorter'

    input:
    tuple val(meta), path(fasta)
    path vs2_db
    val options

    output:
    tuple val(meta), path('final-viral-score.tsv'), emit: all
    tuple val(meta), path("virsorter2-*.txt"), emit: ctg_ids
    path "*.version.txt", emit: version
    
    script:
    def ioptions = initOptions(options)
    def software = getSoftwareName(task.process)
    def prefix   = ioptions.suffix ? "${meta.id}${ioptions.suffix}" : "${meta.id}"
    """
    #!/usr/bin/env bash

    virsorter run $ioptions.args  -w out -i $fasta -j $task.cpus -d $vs2_db
    mv out/final-viral-score.tsv .
    tail -n+2 final-viral-score.tsv | cut -f1 | cut -d'|' -f1 > virsorter2-${prefix}.txt

    virsorter --version | sed 's/.*version //' > ${software}.version.txt
    """
}
