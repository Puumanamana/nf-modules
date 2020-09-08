nextflow.enable.dsl = 2

include { DL_VIRSORTER2_DB; VIRSORTER2 } from './process.nf'


workflow test_db {
    DL_VIRSORTER2_DB(
        [publish_dir: 'test_db']
    )
}

workflow test_virsorter2 {
    fasta = Channel.fromPath("$baseDir/input/sample*.fasta")
        .map{[[id: it.getSimpleName()], it]}
    db = Channel.fromPath()
    
    VIRSORTER2(
        fasta,
        db,
        [publish_dir: 'test_virsorter2']
    ) // doesn't work yet
}

workflow {
    test_db()
    test_virsorter2()
}
