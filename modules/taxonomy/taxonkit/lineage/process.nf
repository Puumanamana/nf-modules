// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

process TAXONKIT_LINEAGE {
    tag "$meta.id"
    label 'process_medium'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }

    container "quay.io/biocontainers/taxonkit:0.6.0--0"
    conda (params.conda ? "bioconda::taxonkit=0.6.0" : null)

    input:
    tuple val(meta), path(taxids)
    path db
    val options

    output:
    tuple val(meta), path("*.txt"), emit: txt
    path "*.version.txt", emit: version

    script:
    def software = getSoftwareName(task.process)
    def ioptions = initOptions(options)
    def prefix   = ioptions.suffix ? "${meta.id}${ioptions.suffix}" : "${meta.id}"
    """
    taxonkit lineage $ioptions.args -r $taxids \\
        --data-dir $db \\
        --threads $task.cpus \\
        > ${prefix}-lineages.txt

    taxonkit version | sed 's/taxonkit //'  > ${software}.version.txt
    """
}
