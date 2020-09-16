nextflow.enable.dsl = 2
include { DL_VIRSORTER_DB; VIRSORTER } from './process'


workflow test_db {
    DL_VIRSORTER_DB(
        [publish_dir: 'test_db']
    )
}

workflow test_virsorter {
    fasta = Channel.fromPath("$baseDir/input/sample*.fasta")
        .map{[[id: it.getSimpleName()], it]}
    db = Channel.fromPath("$HOME/db/virsorter")
    
    VIRSORTER(
        fasta,
        db,
        [publish_dir: 'test_virsorter']
    )
}

workflow {
    // test_db()
    test_virsorter()
}
