include { initOptions; saveFiles ; getSoftwareName } from './functions'

process VIBRANT_DB {
    label "process_low"
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:options, publish_dir:getSoftwareName(task.process), publish_id:"") }

    container 'nakor/vibrant'
    
    output:
    path "$db_name/databases", emit: db
    path "$db_name/files", emit: files

    script:
    def db_name = params.vibrant_db.tokenize('/')[-1]
    """
    mkdir -p "${db_name}/databases" && cd "${db_name}/databases"
    vibrant_dir=\$(dirname \$(which VIBRANT_setup.py))
    cp -r "\$vibrant_dir"/profile_names .
    cp -r "\$vibrant_dir"/../files ..

    wget -qO- http://fileshare.csb.univie.ac.at/vog/vog94/vog.hmm.tar.gz | tar xz
    wget -q ftp://ftp.ebi.ac.uk/pub/databases/Pfam/releases/Pfam32.0/Pfam-A.hmm.gz \
        && gunzip Pfam-A.hmm.gz
    wget -qO- ftp://ftp.genome.jp/pub/db/kofam/archives/2019-08-10/profiles.tar.gz | tar xz

    for v in VOG*.hmm; do 
	    cat \$v >> vog_temp.HMM
    done

    for k in profiles/K*.hmm; do 
	    cat \$k >> kegg_temp.HMM
    done

    rm -r VOG0*.hmm VOG1*.hmm VOG2*.hmm profiles

    hmmfetch -o VOGDB94_phage.HMM -f vog_temp.HMM profile_names/VIBRANT_vog_profiles.txt >> VIBRANT_setup.log
    hmmfetch -o KEGG_profiles_prokaryotes.HMM -f kegg_temp.HMM profile_names/VIBRANT_kegg_profiles.txt >> VIBRANT_setup.log
    
    rm vog_temp.HMM kegg_temp.HMM
    mv Pfam-A.hmm Pfam-A_v32.HMM

    hmmpress VOGDB94_phage.HMM >> VIBRANT_setup.log
    hmmpress KEGG_profiles_prokaryotes.HMM >> VIBRANT_setup.log
    hmmpress Pfam-A_v32.HMM >> VIBRANT_setup.log
    """
}



process VIBRANT_RUN {
    tag {"${meta.id}"}
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }
    container 'nakor/vibrant'
    
	input:
    tuple val(meta), path(fasta)
    path vibrant_db
    path vibrant_files
    val options

	output:
    tuple val(meta), path('*'), emit: all
    tuple val(meta), path("vibrant-*.txt"), emit: ctg_ids
    path "*.version.txt", emit: log

    script:
    def ioptions = initOptions(options)
    def software = getSoftwareName(task.process)
    def prefix   = ioptions.suffix ? "${meta.id}${ioptions.suffix}" : "${meta.id}"
    
    def radical = "${fasta.getSimpleName()}"
    def result_path = "VIBRANT_${radical}/VIBRANT_results_${radical}/VIBRANT_machine_${radical}.tsv"
    """
    VIBRANT_run.py $ioptions.args -i $fasta -t $task.cpus -d $vibrant_db -m $vibrant_files
    awk -F"\\t" '\$2=="virus"' $result_path | cut -d ' ' -f 1 >> vibrant-${prefix}.txt

    VIBRANT_run.py --version | sed 's/VIBRANT //' > ${software}.version.txt
    """
}
