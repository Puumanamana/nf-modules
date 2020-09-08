include { initOptions; saveFiles ; getSoftwareName } from './functions'

process COCONET_RUN {
    tag {"${meta.id}"}
    label 'process_medium'

    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }

    container 'nakor/coconet'
    // conda (params.conda ? "bioconda::coconet-binning=0.54" : null)
    
    input:
    tuple val(meta), file(fasta), file(coverage)
    val options

    output:
    tuple val(meta), path("coconet_*.csv"), emit: bins
    path "*.version.txt", emit: version

    script:
    def ioptions = initOptions(options)
    def software = getSoftwareName(task.process)
    def prefix   = ioptions.suffix ? "${meta.id}${ioptions.suffix}" : "${meta.id}"
    def coverage_arg = coverage[0].getExtension() == 'bam' ? "--bam ${coverage}" : "--h5 ${coverage}"
    """
    coconet run $ioptions.args --fasta $fasta $coverage_arg \\
    --output $prefix \\
    --threads $task.cpus \\
    --min-ctg-len ${params.coconet.min_ctg_len} \\
    --min-prevalence ${params.coconet.min_prevalence} \\
    --min-mapping-quality ${params.coconet.min_mapping_quality} \\
    --min-aln-coverage ${params.coconet.min_aln_coverage}

    cp $prefix/bins_*.csv coconet_${prefix}.csv
        
    coconet --version > ${software}.version.txt
    """
}

