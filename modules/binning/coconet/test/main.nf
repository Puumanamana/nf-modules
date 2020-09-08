#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { COCONET } from '../main.nf' addParams(min_ctg_len: 2048)


workflow test_coconet {
    def input = []
    input = [
        [ id: 'test' ],
        file("${baseDir}/input/contigs.fa", checkIfExists: true),
        file("${baseDir}/input/sample*.bam", checkIfExists: true)
    ]

    COCONET( input,
            [ publish_dir:'test_coconet' ] )
}


workflow {
    test_coconet()
}
