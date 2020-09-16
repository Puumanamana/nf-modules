include { initOptions; saveFiles ; getSoftwareName } from './functions'

process CHECKV {
    tag {"${meta.id}"}
    label 'process_medium'
    publishDir "${params.outdir}/checkv", mode: 'copy'
    
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }
    
    container "quay.io/biocontainers/checkv:0.7.0--py_1"
    conda (params.conda ? "bioconda::checkv=0.7.0" : null)

    input:
    tuple val(meta), path(fasta)
    val options

    output:
    
    script:
    def ioptions = initOptions(options)
    def software = getSoftwareName(task.process)
    def prefix   = ioptions.suffix ? "${meta.id}${ioptions.suffix}" : "${meta.id}"
    """

    checkv -v > ${software}.version.txt
    """
}
