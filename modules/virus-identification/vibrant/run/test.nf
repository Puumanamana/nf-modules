nextflow.enable.dsl = 2

include { VIBRANT_DB; VIBRANT } from './process'


workflow test_dl_db {
    VIBRANT_DB([publish_dir: 'test_db'])
}


workflow test_vibrant {
    fasta = Channel.fromPath("$baseDir/input/sample*.fasta")
        .map{[[id: it.getSimpleName()], it]}
    db = Channel.fromPath()
    VIBRANT(
        fasta,
        db,
        [publish_dir: 'test_vibrant']
    )
}


workflow test {
    test_dl_db()
    test_vibrant()
}
