nextflow.enable.dsl = 2

include { KRAKEN2 } from './main'

workflow {
    input = file(params.fasta, checkIfExists: true)
    kraken2_db = file(params.kraken2_db, checkIfExists: true, type: 'dir')
    KRAKEN2 (
        [[id: input.getSimpleName()], input],
        kraken2_db,
        [publish_dir:'kraken2-run']
    ) 
}

