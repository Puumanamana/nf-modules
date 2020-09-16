#!/usr/bin/env nextflow

nextflow.enable.dsl = 2
include { KAIJU_BUILD; KAIJU } from './process' addParams(kaiju_db_name: 'viruses')


workflow test_dl_db {
    KAIJU_BUILD([ publish_dir:'test_kraken_db' ])
}

workflow test_kaiju {
    def input = []
    input = [
        [ id: 'test' ],
        file("$baseDir/input/genomes-test.fasta.gz", checkIfExists: true)
    ]

    def db = []
    db = file("$baseDir/input/kraken2-dbs/virus")
    KAIJU ( input, db, [ publish_dir:'test_kaiju', args:'--confidence 0.5' ] )
}


workflow {
    test_dl_db()

    // Fails: need for a small db for testing
    // test_kaiju()
}
