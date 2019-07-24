

//somatic_vcf
Channel.fromPath(params.somatic_vcf, type: 'file')
       .set { somatic_vcf_channel }

// fasta
Channel.fromPath(params.fasta, type: 'file')
       .set { fasta_channel }


vcf2maf_channel = somatic_vcf_channel.combine(fasta_channel)


process Vcf2maf {
    tag "$vcf"
    container 'levim/vcf2maf:1.0'
    publishDir "Somatic", mode: 'copy'

    input:
    set file(vcf), file(fasta) from vcf2maf_channel

    output:
    file maf into vcf_variant_eval

    script:

    """
    perl /opt/vcf2maf/vcf2maf.pl \
    --input-vcf $vcf \
    --output-maf maf  \
    --tumor-id H46126 \
    --normal-id H06530 \
    --ref-fasta /vepdata/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa \
    --ncbi-build  GRCh37 \
    --filter-vcf /vepdata/ExAC_nonTCGA.r0.3.1.sites.vep.vcf.gz \
    --vep-path /opt/variant_effect_predictor_89/ensembl-tools-release-89/scripts/variant_effect_predictor \
    --vep-data /vepdata/ \
    --vep-forks 2 \
    --buffer-size 200 \
    --species homo_sapiens     \
    --cache-version 89
    """
}