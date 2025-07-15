**`samtools stats`**

Run `samtools stats` on the mapped `BAM` files output from `vg_snakemake`.
Use the use the `samtools_submit.sh` script to specify the location of the `BAM` files. This script will iterate through and submit individual jobs for each in combination with `samtools_stats.sh`.

**`bcftools stats`**

Run `bcftools stats` on the deepvariant and dysgu VCFs for each sample (not the g.vcf files)

**Mendelian Violations**

Calculate mendelian-violation rate using GATK `VariantEval MendelianViolationEvaluator`

*Setup Instructions*

Pull the singularity image from docker hub
```
singularity pull docker://broadinstitute/gatk@sha256:71b17ee42d149e8ec112603f5305c873ab60d93949ef8bb62a4fff85427f56fb
```

*Run Script*

`gatk_mendel.sh`
