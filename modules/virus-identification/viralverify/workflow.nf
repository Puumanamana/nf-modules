nextflow.enable.dsl = 2

include { DL_PFAM_DB; VIRALVERIFY } from './process.nf'


workflow viralverify {
    take:
    contigs
    options

    main:
    pfam_db = file(params.pfam_db)
    if( !pfam_db.exists() ) {
        pfam_db = DL_PFAM_DB()
    }
    VIRALVERIFY(contigs, pfam_db, options)

    emit:
    all = VIRALVERIFY.out.all
    ctg_ids = VIRALVERIFY.out.ctg_ids
}
