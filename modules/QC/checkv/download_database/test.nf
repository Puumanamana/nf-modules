nextflow.enable.dsl = 2

include { CHECKV_DOWNLOAD_DATABASE } from './process'


workflow test_db {
    CHECKV_DOWNLOAD_DATABASE(
        [publish_dir: 'test_download_db']
    )
}

workflow {
    test_db()
}
