nextflow.enable.dsl = 2

include { TAXONKIT_LINEAGE } from './main'

workflow {
    input = file(params.taxids, checkIfExists: true)
    tax_db = file(params.tax_db, checkIfExists: true)
    TAXONKIT_LINEAGE ([[id: input.getSimpleName()], input], tax_db, [publish_dir:'taxonkit_lineage-run']) 
}

