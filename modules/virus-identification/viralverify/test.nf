nextflow.enable.dsl = 2

include { DL_PFAM_DB; VIRALVERIFY } from './process.nf'


workflow test_db {
    DL_PFAM_DB(
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
