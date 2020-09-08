#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { CONCOCT } from '../main.nf' addParams(min_ctg_len: 1000, max_clusters:100)


workflow test_concoct {
    def input = []
    input = [
        [ id: 'test' ],
        file("${baseDir}/input/contigs.fa", checkIfExists: true),
        file("${baseDir}/input/coverage.tsv", checkIfExists: true)
    ]

    CONCOCT ( input,
              [ publish_dir:'test_metabat2' ] )
}


workflow {
    test_concoct()
}
