nextflow.enable.dsl = 2

include { VIRFINDER } from './process' addParams(virfinder_thresh: 0.05)


workflow test_virfinder {
    fasta = Channel.fromPath("$baseDir/input/sample*.fasta")
        .map{[[id: it.getSimpleName()], it]}
    
    VIRFINDER(
        fasta,
        [publish_dir: 'test_virfinder']
    )
}

workflow {
    test_virfinder()
}
