include { initOptions; saveFiles ; getSoftwareName } from './functions'


process DL_VIRSORTER_DB {
    label 'process_low'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:options, publish_dir:getSoftwareName(task.process), publish_id:"") }
    output:
    path 'vs_db'

    script:
    """
    wget https://zenodo.org/record/1168727/files/virsorter-data-v2.tar.gz
    tar -xvzf virsorter-data-v2.tar.gz
    mv virsorter-data vs_db
    """    
}

process VIRSORTER {
    tag {"${meta.id}"}
    label 'process_medium'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:options, publish_dir:getSoftwareName(task.process), publish_id:"") }
    container 'nakor/virsorter'
    
    input:
    tuple val(meta), path(fasta)
    path vs_db
    val options

    output:
    tuple val(meta), path("virsorter-output-*"), emit: all
    tuple val(meta), path ("virsorter-*.txt"), emit: ctg_ids
    
    script:
    def ioptions = initOptions(options)
    def software = getSoftwareName(task.process)
    def prefix   = ioptions.suffix ? "${meta.id}${ioptions.suffix}" : "${meta.id}"
    """
    wrapper_phage_contigs_sorter_iPlant.pl $ioptions.args \
        -f $fasta \
        --ncpu $task.cpus \
        --wdir virsorter-output-$prefix \
        --data-dir $vs_db --db 1
    
    grep "^VIRSorter" virsorter-output-$prefix/VIRSorter_global-phage-signal.csv \
        | cut -d, -f1 \
        | sed 's/VIRSorter_//' \
        | sed 's/-circular//' \
        > virsorter-${prefix}.txt
    """
}
