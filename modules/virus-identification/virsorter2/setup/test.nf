nextflow.enable.dsl = 2

include { VIRSORTER2_SETUP } from "./process"


workflow test_db {
    VIRSORTER2_SETUP(
        [publish_dir: "test_db"]
    )
}

workflow {
    test_db()
}
