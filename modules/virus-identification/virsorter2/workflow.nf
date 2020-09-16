nextflow.enable.dsl = 2

include { VIRSORTER2_SETUP } from './setup/process'
include { VIRSORTER2_RUN } from './run/process'


workflow virsorter2 {
    take:
    contigs // tuple (meta, fasta)
    options

    main:
    vs2_db = file(params.vs2_db)
    if(!vs2_db.exists()) {
        vs2_db = VIRSORTER2_SETUP()
    }
    VIRSORTER2_RUN(contigs, vs2_db, options)

    emit:
    all = VIRSORTER2_RUN.out.all
    ctg_ids = VIRSORTER2_RUN.out.ctg_ids
}

