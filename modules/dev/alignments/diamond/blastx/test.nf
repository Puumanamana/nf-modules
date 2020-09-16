nextflow.enable.dsl = 2

include {DL_PROTEIN_DB; DIAMOND_BLASTX} from './process'


workflow test_db_dl {
    DL_PROTEIN_DB()
}

workflow test_diamond_blastx {
    fasta = Channel.fromPath("input/sample*.fasta")
        .map{[[id: it.getSimpleName()], it]}
    db = file("input/db")
    DIAMOND_BLASTX(fasta, db, [:])
}

workflow {
    test_db_dl()
    test_diamond_blastx()
}
