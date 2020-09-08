include { initOptions; saveFiles ; getSoftwareName } from './functions'

process KAIJU_BUILD {
    label 'process_low'

    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:options, publish_dir:getSoftwareName(task.process), publish_id:'') }

    container 'nanozoo/kaiju'
    conda (params.conda ? "bioconda::kaiju=1.7.3" : null)

    input:
    val options
    
    output:
    path 'kaijudb', emit: db
    path "*.version.txt", emit: version

    script:
    def software = getSoftwareName(task.process)
    def ioptions = initOptions(options)
    """
    mkdir kaijudb && cd kaijudb && \\
    kaiju-makedb $ioptions.args \\
        -s $params.kaiju_db_name \\
        -t $task.cpus && \\
    cd ..

    echo \$(kaiju -h 2>&1) | head -1 | cut -d ' ' -f2  > ${software}.version.txt
    """
}

process KAIJU {
    tag {"${meta.id}"}
    label 'process_medium'

    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }
    
    container 'nanozoo/kaiju'
    conda (params.conda ? "bioconda::kaiju=1.7.3" : null)

	input:
    tuple val(meta), path(fasta)
    path db
    val options

	output:
    tuple val(meta), path('*-taxonomy.tsv'), emit: taxonomy
    tuple val(meta), path('*-taxids.txt'), emit: taxids
    path "*.version.txt", emit: version

    script:
    def ioptions = initOptions(options)
    def software = getSoftwareName(task.process)
    def prefix   = ioptions.suffix ? "${meta.id}${ioptions.suffix}" : "${meta.id}"
    """
    kaiju -t $db/nodes.dmp -f $db/kaiju_db_*.fmi -i $fasta -o ${prefix}-taxonomy.tsv

    grep -E '^C' ${prefix}-taxonomy.tsv | cut -f3 > ${prefix}-taxids.txt    

    echo \$(kaiju -h 2>&1) | head -1 | cut -d ' ' -f2  > ${software}.version.txt    
    """
}
