include { initOptions; saveFiles ; getSoftwareName } from './functions'

process COCONET_RUN {
    tag {"${meta.id}"}
    label 'process_medium'

    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }

    container 'nakor/coconet'
    // Submit bioconda release once it's published
    // conda (params.conda ? "bioconda::coconet-binning=0.54" : null)
    
    input:
    tuple val(meta), file(fasta), file(coverage)
    val options

    output:
    tuple val(meta), path("coconet_bins-*.csv"), emit: bins
    tuple val(meta), path("coconet*"), emit: all
    path "*.version.txt", emit: version

    script:
    def ioptions = initOptions(options)
    def software = getSoftwareName(task.process)
    def prefix   = ioptions.suffix ? "${meta.id}${ioptions.suffix}" : "${meta.id}"
    def coverage_arg = coverage[0].getExtension() == 'bam' ? "--bam ${coverage}" : "--h5 ${coverage}"
    """
    coconet run $ioptions.args --fasta $fasta $coverage_arg --output coconet-$prefix --threads $task.cpus
    cp coconet-$prefix/bins_*.csv coconet_bins-${prefix}.csv

    coconet --version > ${software}.version.txt
    """
}

