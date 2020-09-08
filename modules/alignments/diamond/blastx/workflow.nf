nextflow.enable.dsl = 2

include {DL_VIRAL_PROTEIN_DB; DIAMOND_BLASTX} from ./main.nf


workflow diamond_blastx {
    take:
    contigs // tuple (meta, fasta)
    options

    main:
    vir_prot_db = file(params.vir_prot_db)
    if(!vir_prot_db.exists()) {
        vir_prot_db = DL_VIRAL_PROTEIN_DB()
    }
    DIAMOND_BLASTX(contigs, vir_prot_db, options)

    emit:
    all = DIAMOND_BLASTX.out.all
    ctg_ids = DIAMOND_BLASTX.out.ctg_ids
}


workflow test {
    fasta = Channel.fromPath("test_data/sample*.fasta")
        .map{[[id: it.getSimpleName()], it]}
    diamond_blastx(fasta, [:])
}
