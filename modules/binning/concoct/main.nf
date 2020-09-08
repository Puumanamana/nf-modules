include { initOptions; saveFiles ; getSoftwareName } from './functions'

process CONCOCT {
    tag {"${meta.id}"}
    label 'process_medium'

    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }
    
    container "flowcraft/concoct"
    conda (params.conda ? "bioconda::concoct=1.1.0" : null)

    input:
    tuple val(meta), path(fasta), path(coverage)
    val options

    output:
    tuple val(meta), path("concoct_${meta.id}.csv"), emit: bins
    path "*.version.txt", emit: version

    script:
    def ioptions = initOptions(options)
    def software = getSoftwareName(task.process)
    def prefix   = ioptions.suffix ? "${meta.id}${ioptions.suffix}" : "${meta.id}"    
    """
    concoct $ioptions.args --threads $task.cpus \\
        --composition_file ${fasta} --coverage_file ${coverage} \\
        --clusters ${params.concoct.max_clusters} \\
        --length_threshold ${params.concoct.min_ctg_len} \\
        --no_original_data

    tail -n+2 clustering_gt${params.concoct.min_ctg_len}.csv > concoct_${meta.id}.csv

    concoct --version > ${software}.version.txt
    """
}
