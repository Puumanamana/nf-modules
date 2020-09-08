include { initOptions; saveFiles ; getSoftwareName } from './functions'

process MAXBIN2 {
    tag {"${meta.id}"}
    label 'process_medium'

    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }

    container 'nanozoo/maxbin2'
    // issue with the bioconda repository (missing lwp-simple perl library)
    conda (params.conda ? 'bioconda::maxbin2=2.2.7 perl-lwp-simple' : null)

    input:
    tuple val(meta), path(fasta), path(coverage)
    val options

    output:
    tuple val(meta), path('*.csv'), emit: bins
    path "*.version.txt", emit: version
    
    script:
    def ioptions = initOptions(options)
    def software = getSoftwareName(task.process)
    def prefix   = ioptions.suffix ? "${meta.id}${ioptions.suffix}" : "${meta.id}"
    def cov_arg = coverage.withIndex()
        .collect{v, i -> "-abund${i+1} ${v}"}
        .join(' ')
        .replaceFirst('abund1', 'abund')
    """
    run_MaxBin.pl -contig $fasta $cov_arg \
         -out maxbin \
         -min_contig_length ${params.maxbin2.min_ctg_len} \
         -thread $task.cpus

    # Make assignment file
    for fa in `ls maxbin.*.fasta`; do
        bin_id=\$(echo \$fa | cut -d '.' -f2 | sed 's/^0*//')
        grep '^>' \$fa | cut -c 2- | awk -v b=\$bin_id '{print \$1","b}' >> maxbin2_${meta.id}.csv
    done

    run_MaxBin.pl -v | head -1 > ${software}.version.txt
    """
}
