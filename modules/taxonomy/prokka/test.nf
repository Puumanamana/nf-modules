#!/usr/bin/env nextflow

nextflow.enable.dsl = 2
include { PROKKA_SETUPDB; PROKKA } from './process'


workflow test_db {
    PROKKA_SETUPDB ( [ publish_dir:'test_prokka_db' ] )
}

workflow test_prokka {
    def input = [
        [ id: 'test' ],
        file("$baseDir/input/viral.fna", checkIfExists: true)
    ]

    def db = file("$baseDir/input/db")
    PROKKA ( input, db, [ publish_dir:'test_prokka' ] )
}


workflow {
    test_db()
    test_prokka()
}
