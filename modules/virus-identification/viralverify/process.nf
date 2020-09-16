include { initOptions; saveFiles ; getSoftwareName } from './functions'


process VIRALVERIFY_DB {
    label 'process_low'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:options, publish_dir:getSoftwareName(task.process), publish_id:"") }
    
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
    label 'process_medium'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:options, publish_dir:getSoftwareName(task.process), publish_id:"") }
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
    def software = getSoftwareName(task.process)
    def prefix   = ioptions.suffix ? "${meta.id}${ioptions.suffix}" : "${meta.id}"
    """
    viralverify.py $ioptions.args -f ${fasta} -o ./ --hmm ${pfam_db} -t $task.cpus
    cat Prediction_results_fasta/*virus* | grep '^>' | cut -c2- > viralverify-${prefix}.txt

    echo -1 > ${software}.version.txt # No version yet
    """
}

