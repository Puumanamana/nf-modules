nextflow.enable.dsl = 2

include { DL_VIBRANT_DB; VIBRANT } from './process.nf'


workflow test_dl_db {
    DL_VIBRANT_DB([publish_dir: 'test_db'])
}


workflow test_vibrant {
    fasta = Channel.fromPath("$baseDir/input/sample*.fasta")
        .map{[[id: it.getSimpleName()], it]}
    db = Channel.fromPath()
    vibrant(
        fasta,
        db,
        [publish_dir: 'test_vibrant']
    )
}


workflow test {
    test_dl_db()
    test_vibrant()
}
