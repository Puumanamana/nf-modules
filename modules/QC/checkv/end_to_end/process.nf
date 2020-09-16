include { initOptions; saveFiles ; getSoftwareName } from './functions'

process CHECKV_END_TO_END {
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
    path db
    val options

    output:
    tuple val(meta), path("checkv-*"), emit: all
    path "*.version.txt", emit: version
    
    script:
    def ioptions = initOptions(options)
    def software = getSoftwareName(task.process)
    def prefix   = ioptions.suffix ? "${meta.id}${ioptions.suffix}" : "${meta.id}"
    """
    checkv end_to_end -d $db -t $task.cpus $fasta checkv-${meta.id}
    checkv --help | head -1 | cut -d ' ' -f2 | sed 's/[v:]//g' > ${software}.version.txt
    """
}
