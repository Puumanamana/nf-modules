nextflow.enable.dsl = 2

include { CHECKV_END_TO_END } from './process'


workflow test_checkv_endtoend {
    fasta = Channel.fromPath("$baseDir/input/sample*.fasta")
        .map{[[id: it.getSimpleName()], it]}
    db = Channel.fromPath()
    CHECKV_END_TO_END(
        fasta,
        db,
        [publish_dir: 'test_end-to-end']
    )
}

workflow {
    test_checkv_endtoend()
}
