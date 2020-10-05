include { initOptions; saveFiles ; getSoftwareName } from './functions'

process PROKKA_SETUPDB {
    label 'process_low'

    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:options, publish_dir:getSoftwareName(task.process), publish_id:'') }

    container 'quay.io/biocontainers/prokka:1.14.6--pl526_0'
    conda (params.conda ? "bioconda::prokka=1.14.6-0" : null)

    input:
    val options
    
    output:
    path "db", emit: db
    path "*.version.txt", emit: version

    script:
    def software = getSoftwareName(task.process)
    def ioptions = initOptions(options)
    """
    cp -r \$(dirname \$(which prokka))/../db .
    prokka $ioptions.args --dbdir db --setupdb
    prokka --version | cut -d ' ' -f2  > ${software}.version.txt    
    """
}

process PROKKA {
    tag {"${meta.id}"}
    label 'process_medium'

    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }
    
    container 'quay.io/biocontainers/prokka:1.14.6--pl526_0'
    conda (params.conda ? "bioconda::prokka=1.14.6-0" : null)

	input:
    tuple val(meta), path(fasta)
    path db
    val options

	output:
    path "*", emit: annotation
    path "*.version.txt", emit: version

    script:
    def ioptions = initOptions(options)
    def software = getSoftwareName(task.process)
    def prefix   = ioptions.suffix ? "${meta.id}${ioptions.suffix}" : "${meta.id}"
    """
    prokka --cpus $task.cpus $ioptions.args $fasta

    prokka --version | cut -d ' ' -f2  > ${software}.version.txt    
    """
}
