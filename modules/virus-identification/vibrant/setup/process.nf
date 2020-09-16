include { initOptions; saveFiles ; getSoftwareName } from './functions'


process VIBRANT_SETUP {
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:options, publish_dir:getSoftwareName(task.process), publish_id:"") }
    container 'nakor/vibrant'
    
	input:
    tuple val(meta), path(fasta)
    path vibrant_db
    path vibrant_files
    val options

	output:
    tuple val(meta), path('*'), emit: all
    tuple val(meta), path("vibrant-*.txt"), emit: ctg_ids
    path "*.version.txt", emit: version

    script:
    def ioptions = initOptions(options)
    def software = getSoftwareName(task.process)
    """
    VIBRANT_setup.py $ioptions.args

    VIBRANT_setup.py --version | sed 's/VIBRANT //' > ${software}.version.txt
    """
}
