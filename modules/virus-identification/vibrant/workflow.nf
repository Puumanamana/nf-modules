nextflow.enable.dsl = 2

include { VIBRANT_DB; VIBRANT } from './process'


workflow vibrant {
    take:
    contigs
    options

    main:
    vibrant_data = [db: file("${params.vibrant_db}/databases"), files: file("${params.vibrant_db}/files")]
    if(!vibrant_data.db.exists()) {
        vibrant_data = VIBRANT_DB()
    }
    VIBRANT(contigs, vibrant_data.db, vibrant_data.files, options)

    emit:
    all = VIBRANT.out.all
    ctg_ids = VIBRANT.out.ctg_ids
}
