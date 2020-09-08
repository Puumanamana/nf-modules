#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { KRAKEN2 } from '../main.nf'


workflow test_kraken {
    def input = []
    input = [
        [ id: 'test' ],
        file("${baseDir}/input/genomes-test.fasta.gz", checkIfExists: true)
    ]

    def db = []
    db = file("${baseDir}/input/kraken2-dbs/virus")
    KRAKEN2 ( input, db, [ publish_dir:'test_kraken', args:'--confidence 0.5' ] )
}


workflow {
    test_kraken()
}
