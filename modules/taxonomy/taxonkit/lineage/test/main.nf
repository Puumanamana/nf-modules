#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { TAXONKIT_LINEAGE } from '../main.nf'


workflow test_taxonkit_lineage {
    def input = []
    input = [
        [ id: 'test' ],
        file("${baseDir}/input/taxids.txt", checkIfExists: true)
    ]

    def db = []
    db = file("${baseDir}/input/taxonomy")
    TAXONKIT_LINEAGE ( input, db, [ publish_dir:'test_taxonkit_lineage' ] )
}


workflow {
    test_taxonkit_lineage()
}
