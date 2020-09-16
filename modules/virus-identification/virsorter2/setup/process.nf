include { initOptions; saveFiles ; getSoftwareName } from "./functions"


process VIRSORTER2_SETUP {
    label "process_low"
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:options, publish_dir:getSoftwareName(task.process), publish_id:"") }
    container "nakor/virsorter"

    output:
    path "virsorter2_db", emit: db
    path "*.version.txt", emit: version

    script:
    def software = getSoftwareName(task.process)
    """
    virsorter setup -d virsorter2_db -j $task.cpus
    virsorter --version | sed "s/.*version //" > ${software}.version.txt
    """    
}
