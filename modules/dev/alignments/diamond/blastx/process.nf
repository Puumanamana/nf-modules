include { initOptions } from '../functions'


// Needs to be more generic
process DL_VIRAL_PROTEIN_DB {
    publishDir params.dbdir, mode: 'copy'
    container = 'nakor/virus_extraction'

    output:
    path 'refseq_viral_proteins.dmnd'

    script:
    """
    wget https://ftp.ncbi.nlm.nih.gov/refseq/release/viral/viral.{1,2}.protein.faa.gz
    cat viral.*.protein.faa.gz | unpigz -p $task.cpus > viral.protein.faa
    diamond makedb --threads $task.cpus --in viral.protein.faa --db refseq_viral_proteins
    """        
}

// Same
process DIAMOND_BLASTX {
    tag {"${meta.id}"}
    publishDir params.outdir+"/diamond", mode: "copy"
    // container = 'nakor/virus_extraction'
    
    input:
    tuple val(meta), path(fasta)
    path db
    val options

    output:
    tuple val(meta), path('*'), emit: 'all'
    tuple val(meta), path("diamond-${meta.id}.txt"), emit: 'ctg_ids'    
    
    script:
    def ioptions = initOptions(options)
    """
    diamond blastx $ioptions.args -b 6 -d ${db} -q ${fasta} -o diamond_matches_on_refseq_${meta.id}.m8 --threads $task.cpus
    cut -f1 diamond_matches_on_refseq_${meta.id}.m8 | uniq -c | sort -rnk1 \
        | awk '{OFS=","}{print \$2,\$1}' > diamond_ctg_hit_counts_${meta.id}.txt
    cut -d, -f1 diamond_ctg_hit_counts_${meta.id}.txt > diamond-${meta.id}.txt
    """
}
