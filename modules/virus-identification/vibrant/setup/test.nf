nextflow.enable.dsl = 2

include { VIBRANT_SETUP } from './process'


workflow test_dl_db {
    VIBRANT_SETUP([publish_dir: 'test_setup'])
}


workflow test {
    test_dl_db()
}
