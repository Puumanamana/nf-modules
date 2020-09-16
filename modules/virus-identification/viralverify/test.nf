nextflow.enable.dsl = 2

include { VIRALVERIFY_DB; VIRALVERIFY } from './process'


workflow test_db {
    VIRALVERIFY_DB(
        [publish_dir: 'test_db']
    )
}

workflow test_viralverify {
    fasta = Channel.fromPath("$baseDir/input/sample*.fasta")
        .map{[[id: it.getSimpleName()], it]}
    db = Channel.fromPath()
    
    VIRALVERIFY(
        fasta,
        db,
        [publish_dir: 'test_viralverify']
    )
}

workflow {
    test_db()
    test_viralverify()
}
