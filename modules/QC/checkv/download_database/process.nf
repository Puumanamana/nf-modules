include { initOptions; saveFiles ; getSoftwareName } from './functions'

process CHECKV_DOWNLOAD_DATABASE {
    label 'process_low'
    
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:options, publish_dir:getSoftwareName(task.process), publish_id:"") }
    
    container "quay.io/biocontainers/checkv:0.7.0--py_1"
    conda (params.conda ? "bioconda::checkv=0.7.0" : null)

    output:
    path "checkv*", emit: db
    path "*.version.txt", emit: version
    
    script:
    def software = getSoftwareName(task.process)
    """
    checkv download_database .
    checkv --help | head -1 | cut -d ' ' -f2 | sed 's/[v:]//g' > ${software}.version.txt
    """
}
