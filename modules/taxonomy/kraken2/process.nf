include { initOptions; saveFiles ; getSoftwareName } from './functions'

process KRAKEN2_BUILD {
    tag {"download_kraken_db"}
    label 'process_low'

    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:options, publish_dir:getSoftwareName(task.process), publish_id:'') }

    container 'staphb/kraken2'
    conda (params.conda ? "bioconda::kraken2=2.0.9beta" : null)

    input:
    val options
    
    output:
    path 'kraken2-standard-db', emit: db
    path "*.version.txt", emit: version

    script:
    def software = getSoftwareName(task.process)
    def ioptions = initOptions(options)
    """
    kraken2-build $ioptions.args \\
        --threads $task.cpus \\
        --db kraken2-db

    kraken2-build -v | sed 's/.* version //' > ${software}.version.txt
    """
}

process KRAKEN2 {
    tag {"${meta.id}"}
    label 'process_medium'

    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }
    
    container 'staphb/kraken2:2.0.8-beta_hv'
    conda (params.conda ? "bioconda::kraken2=2.0.9beta" : null)

	input:
    tuple val(meta), path(fasta)
    path db
    val options

	output:
    tuple val(meta), path('*-report.tsv'), emit: report
    tuple val(meta), path('*-taxonomy.tsv'), emit: taxonomy
    tuple val(meta), path('*-taxids.txt'), emit: taxids
    path "*.version.txt", emit: version

    script:
    def ioptions = initOptions(options)
    def software = getSoftwareName(task.process)
    def prefix   = ioptions.suffix ? "${meta.id}${ioptions.suffix}" : "${meta.id}"
    """
    kraken2 $ioptions.args \\
        --threads $task.cpus \\
        --db $db \\
        --confidence $params.confidence \\
        --report ${prefix}-report.tsv \\
        --output ${prefix}-taxonomy.tsv \\
        $fasta

    grep -E '^C' ${prefix}-taxonomy.tsv | cut -f3 > ${prefix}-taxids.txt
    
    kraken2 -v | head -1 | sed 's/.* version //' > ${software}.version.txt
    """
}
