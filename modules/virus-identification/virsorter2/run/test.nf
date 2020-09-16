nextflow.enable.dsl = 2

include { VIRSORTER2_RUN } from './process'


workflow test_virsorter2 {
    fasta = Channel.fromPath("$baseDir/input/sample*.fasta")
        .map{[[id: it.getSimpleName()], it]}
    db = Channel.fromPath()
    
    VIRSORTER2_RUN(
        fasta,
        db,
        [publish_dir: 'test_virsorter2']
    )
}

workflow {
    test_virsorter2()
}
