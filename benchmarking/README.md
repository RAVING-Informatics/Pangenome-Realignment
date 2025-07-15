**`samtools stats`**

Run `samtools stats` on the mapped `BAM` files output from `vg_snakemake`.
Use the use the `samtools_submit.sh` script to specify the location of the `BAM` files. This script will iterate through and submit individual jobs for each in combination with `samtools_stats.sh`.

**`bcftools stats`**

Run `bcftools stats` on the deepvariant and dysgu VCFs for each sample (not the g.vcf files). 

This is to generate a plot of the number of variants of a certain variant quality score. See attached plot for example.

*Inputs*

- Use the individual deepvariant VCFs i.e. `D09-468.hprc-v1.1-mc-chm13.surj_realn.snv_indels.vcf.gz`
- Use the cohort deepvariant callsets i.e. `hprc-v1.1-mc-chm13_dv_glnexus_VEP.ann.vcf.gz`

**Coding regions**

To view variant quality scores for the exome, subset the cohort VCF file to include only exons using a genome annotation file:

- T2T-CHM13:
```
wget https://s3-us-west-2.amazonaws.com/human-pangenomics/T2T/CHM13/assemblies/annotation/chm13.draft_v2.0.gene_annotation.gff3
```
- GRCh38:
```
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_35/gencode.v35.annotation.gff3.gz
```

```
#create bed file to include only exons
zgrep "protein_coding" $gtf | awk '$3 == "exon" {print $1"\t"$4-1"\t"$5}' > protein_coding_{genome}.bed
# use bcftools view to subset vcf to only exons and index output
bcftools view -R protein_coding_chm13.bed -Oz -o hprc-v1.1-mc-chm13_dv_glnexus_VEP.gff.exons.vcf.gz hprc-v1.1-mc-chm13_dv_glnexus_VEP.ann.vcf.gz
tabix -p vcf hprc-v1.1-mc-chm13_dv_glnexus_VEP.gff.exons.vcf.gz
```

**Mendelian Violations**

Calculate mendelian-violation rate using GATK `VariantEval MendelianViolationEvaluator`

*Inputs*

Use the cohort deepvariant callsets annotated with VEP: 
- `/Volumes/PERKINS-LL-001/Sequencing/wgs/secondary/Pangenome_realignment/annotated/hprc-v1.1-mc-chm13_dv_glnexus_VEP.ann.vcf.gz`
- `/Volumes/PERKINS-LL-001/Sequencing/wgs/secondary/Pangenome_realignment/annotated/hprc-v1.1-mc-grch38_dv_glnexus_VEP.ann.vcf.gz`

*Setup Instructions*

Pull the singularity image from docker hub
```
singularity pull docker://broadinstitute/gatk@sha256:71b17ee42d149e8ec112603f5305c873ab60d93949ef8bb62a4fff85427f56fb
```

*Run Script*

`gatk_mendel.sh`
