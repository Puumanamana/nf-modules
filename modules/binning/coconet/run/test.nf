#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { COCONET_RUN } from './process.nf'

workflow test_coconet_run {
    def input = []
    input = [
        [ id: 'test' ],
        file("input/contigs.fa", checkIfExists: true),
        file("input/sample*.bam", checkIfExists: true)
    ]

    COCONET_RUN (
        input,
        [ publish_dir:'test_coconet' ]
    )
}


workflow {
    test_coconet_run()
}
