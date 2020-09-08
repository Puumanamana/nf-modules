include { initOptions; saveFiles ; getSoftwareName } from './functions'

process METABAT2 {
    tag {"${meta.id}"}
    label 'process_low'

    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }
    
    container 'nanozoo/metabat2'
    conda (params.conda ? "bioconda::metabat2=2.15" : null)

    input:
    tuple val(meta), path(fasta), path(coverage)
    val options

    output:
    tuple val(meta), path("metabat2_${meta.id}.csv"), emit: bins
    path "*.version.txt", emit: version
    
    script:
    def ioptions = initOptions(options)
    def software = getSoftwareName(task.process)
    def prefix   = ioptions.suffix ? "${meta.id}${ioptions.suffix}" : "${meta.id}"
    """
    gzip -c $fasta > contigs.fasta.gz
    metabat2 --inFile contigs.fasta.gz --abdFile $coverage \\
        --outFile metabat2_${meta.id}.csv \\
        --minContig ${params.metabat2.min_ctg_len} \\
        --saveCls \\
        --onlyLabel \\
        --numThreads $task.cpus

    rm contigs.fasta.gz    
    sed -i 's/\\t/,/' metabat2_${meta.id}.csv

    metabat2 -h 2>&1 | head | grep version > ${software}.version.txt
    """
}

