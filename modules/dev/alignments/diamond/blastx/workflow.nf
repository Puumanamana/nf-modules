nextflow.enable.dsl = 2

include {DL_PROTEIN_DB; DIAMOND_BLASTX} from './process.nf'


workflow diamond_blastx {
    take:
    contigs // tuple (meta, fasta)
    options

    main:
    db = file(params.db)
    if( !db.exists() ) {
        db = DL_PROTEIN_DB()
    }
    DIAMOND_BLASTX(contigs, db, options)

    emit:
    all = DIAMOND_BLASTX.out.all
    ctg_ids = DIAMOND_BLASTX.out.ctg_ids
}
