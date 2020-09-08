nextflow.enable.dsl = 2

include { DL_VIRSORTER2_DB; VIRSORTER2 } from './process.nf'


workflow virsorter2 {
    take:
    contigs // tuple (meta, fasta)
    options

    main:
    vs2_db = file(params.vs2_db)
    if(!vs2_db.exists()) {
        vs2_db = DL_VIRSORTER2_DB()
    }
    VIRSORTER2(contigs, vs2_db, options)

    emit:
    all = VIRSORTER2.out.all
    ctg_ids = VIRSORTER2.out.ctg_ids
}

