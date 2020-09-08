nextflow.enable.dsl = 2

include { KAIJU } from './process'

workflow {
    input = file(params.fasta, checkIfExists: true)
    kaiju_db = file(params.kaiju_db, checkIfExists: true, type: 'dir')
    KAIJU (
        [[id: input.getSimpleName()], input],
        kaiju_db,
        [publish_dir:'kaiju-run']
    ) 
}

