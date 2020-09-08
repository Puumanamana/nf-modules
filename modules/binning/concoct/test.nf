#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { CONCOCT } from './process.nf'


workflow test_concoct {
    def input = []
    input = [
        [ id: 'test' ],
        file("input/contigs.fa", checkIfExists: true),
        file("input/coverage.tsv", checkIfExists: true)
    ]

    CONCOCT (
        input,
        [ publish_dir:'test_concoct' ]
    )
}


workflow {
    test_concoct()
}
