include { initOptions } from './functions'

process DL_PFAM_DB {
    tag {"download_pfam_db"}
    publishDir params.dbdir, mode: 'copy'
    container 'nakor/virus_extraction'
    
    output:
    file('Pfam-A.hmm')

    script:
    """
    wget ftp://ftp.ebi.ac.uk/pub/databases/Pfam/releases/Pfam33.1/Pfam-A.hmm.gz 
    unpigz -p $task.cpus Pfam-A.hmm.gz
    """
}

process VIRALVERIFY {
    tag {"${meta.id}"}
    publishDir params.outdir+"/viralverify", mode: "copy"
    container 'nakor/virus_extraction'
    
	input:
    tuple val(meta), path(fasta)
    path pfam_db
    val options

	output:
    tuple val(meta), path('Prediction_results_fasta/*'), emit: all
    tuple val(meta), path("viralverify-${meta.id}.txt"), emit: ctg_ids

    script:
    def ioptions = initOptions(options)
    """
    viralverify.py $ioptions.args -f ${fasta} -o ./ --hmm ${pfam_db} -t $task.cpus
    cat Prediction_results_fasta/*virus* | grep '^>' | cut -c2- > viralverify-${meta.id}.txt
    """
}

