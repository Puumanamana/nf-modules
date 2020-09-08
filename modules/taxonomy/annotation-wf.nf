nextflow.enable.dsl = 2

include { KRAKEN2 } from './kraken2/main'
include { TAXONKIT_LINEAGE } from './taxonkit/lineage/main.nf'

workflow {
    fasta = Channel.fromFilePairs("${params.fasta}", size: 1).map{[[id: it[0]], it[1]]}
    kraken2_db = file("${params.kraken2_db}", type: 'dir', checkIfExists: true)
    taxonkit_db = file("${params.tax_db}", type: 'dir', checkIfExists: true)

    KRAKEN2 ( fasta, kraken2_db, [ publish_dir: "kraken2" ] )
    TAXONKIT_LINEAGE ( KRAKEN2.out.taxids, taxonkit_db, [ publish_dir: "taxonkit" ] )
}
