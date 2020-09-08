nextflow.enable.dsl = 2

include {DL_VIRSORTER_DB; VIRSORTER} from './process.nf'

workflow virsorter {
    take:
    contigs // tuple (meta, fasta)
    options

    main:
    vs_db = file(params.vs_db)
    if(!vs_db.exists()) {
        vs_db = DL_VIRSORTER_DB()
    }
    VIRSORTER(contigs, vs_db, options)

    emit:
    all = VIRSORTER.out.all
    ctg_ids = VIRSORTER.out.ctg_ids
}
