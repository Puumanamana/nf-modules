nextflow.enable.dsl = 2

include { initOptions } from '../functions'

process FILTER_CONTIGS {
	tag {"${meta.id}"}
    container 'nakor/virus_extraction'
	publishDir "${params.outdir}/contigs_gt${params.min_ctg_len}", mode: "copy"

	input:
    tuple val(meta), path(assembly)

	output:
    tuple val(meta), path("*.fasta")
    
	script:
    """
    seqtk seq -L ${params.min_ctg_len} ${assembly} > ${assembly.getSimpleName()}_gt${params.min_ctg_len}.fasta
    """
}

process CONTIGS_FROM_IDS {
	tag {"${meta.id}"}
    container 'nakor/virus_extraction'
	publishDir params.outdir, mode: "copy"

	input:
    tuple val(meta), path(assembly), path(contig_ids)

	output:
    tuple val(meta), path("viral-contigs-combined_${meta.id}.fasta")
    
	script:
    all_ids = contig_ids.join('", "')
    """
    #!/usr/bin/env python3

    from pathlib import Path
    from Bio import SeqIO

    def extract_contigs(fasta, output, *txt):
        viral_ids = {ctg.strip().split(',')[0].split()[0] for f in txt for ctg in open(f)}

        viral_sequences = []
        for ctg in SeqIO.parse(fasta, 'fasta'):
            if ctg.id in viral_ids:
                viral_sequences.append(ctg)

        SeqIO.write(viral_sequences, output, 'fasta-2line')

    extract_contigs("${assembly}", "viral-contigs-combined_${meta.id}.fasta", *["${all_ids}"])
    """
}

process SUMMARIZE_CALLS {
    publishDir params.outdir, mode: "copy"
    container 'nakor/virus_extraction'
    
    input:
    val meta
    path contig_ids

    output:
    path 'summary*.csv'

    script:
    def samples = meta.samples.value.join('", "')
    def tools = meta.tools.join('", "')
    """
    #!/usr/bin/env python3

    from pathlib import Path
    from itertools import combinations
    import pandas as pd

    def summarize(sample, tools):

        files_s = list(Path('.').glob(f'*{sample}*'))

        ids = {}
        summary = []

        for t in tools:
            file_s_t = next(f for f in files_s if t.lower() in str(f).lower())
            ids[t] = {line.strip().split()[0].replace('.','_') for line in open(file_s_t)}
            summary.append([t, t, len(ids[t])])

        # intersection = set.intersection(*[ids[t] for t in tools])
        # union = set.union(*[ids[t] for t in tools])

        for (t1, t2) in combinations(tools, 2):
            summary.append([t1, t2, len(ids[t1].intersection(ids[t2]))])
    
        summary_df = (pd.DataFrame(summary, columns=['tool1', 'tool2', 'intersection'])
                        .pivot('tool1', 'tool2', 'intersection')
                        .applymap(lambda x: x if pd.isnull(x) else "{:,}".format(int(x))))

        return summary_df

    for sample in ["$samples"]:
        summary = summarize(sample, ["$tools"])
        summary.to_csv(f"summary_{sample}.csv")

    """
}
