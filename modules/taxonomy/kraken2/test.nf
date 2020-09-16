#!/usr/bin/env nextflow

nextflow.enable.dsl = 2
include { KRAKEN2_BUILD; KRAKEN2 } from './process'


workflow test_dl_db {
    KRAKEN2_BUILD([
        publish_dir:'test_db',
        args:'--standard'
    ]
    )
}

workflow test_kraken {

    KRAKEN2 (
        [
            [ id: 'test' ],
            file("$baseDir/input/genomes-test.fasta.gz", checkIfExists: true)
        ],
        file("$baseDir/input/db"),
        [
            publish_dir:'test_kraken',
            args:'--confidence 0.5'
        ]
    )
}


workflow {
    test_dl_db()
    test_kraken()
}
