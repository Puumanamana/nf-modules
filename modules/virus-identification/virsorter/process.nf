nextflow.enable.dsl = 2

include { initOptions } from './functions'

process DL_VIRSORTER_DB {
    publishDir params.dbdir, mode: 'copy'

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
    container 'nakor/virsorter'
    
    publishDir params.outdir+"/virsorter", mode: "copy"

    input:
    tuple val(meta), path(fasta)
    path vs_db
    val options

    output:
    tuple val(meta), path('vs_out'), emit: all
    tuple val(meta), path ("virsorter-${meta.id}.txt"), emit: ctg_ids
    
    script:
    def ioptions = initOptions(options)
    """
    wrapper_phage_contigs_sorter_iPlant.pl $ioptions.args \
        -f $fasta \
        --ncpu $task.cpus \
        --wdir vs_out \
        --data-dir $vs_db --db 1
    
    grep "^VIRSorter" vs_out/VIRSorter_global-phage-signal.csv \
        | cut -d, -f1 \
        | sed 's/VIRSorter_//' \
        | sed 's/-circular//' \
        > virsorter-${meta.id}.txt
    """
}
