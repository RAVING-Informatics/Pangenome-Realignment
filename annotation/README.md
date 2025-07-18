## Annotate HPRCv1.1-aligned variants using VEP as part of nf-core/sarek

**1) Setup VEP for both chm13 and grch38 data**
- Download cache for grch38 data, available [here](https://ftp.ensembl.org/pub/release-114/variation/indexed_vep_cache/homo_sapiens_vep_114_GRCh38.tar.gz)
- Download cache for chm13 data, available [here](https://ftp.ensembl.org/pub/rapid-release/species/Homo_sapiens/GCA_009914755.4/ensembl/variation/2022_10/indexed_vep_cache/Homo_sapiens-GCA_009914755.4-2022_10.tar.gz)
- Download grch38 reference genome, available [here](https://storage.googleapis.com/gcp-public-data--broad-references/hg38/v0/dragen_reference/Homo_sapiens_assembly38_masked.fasta)
- Download chm13 reference genome, available [here](https://storage.googleapis.com/gcp-public-data--broad-references/t2t/v2/chm13v2.0.maskedY.rCRS.EBV.fasta)

**2) Run VEP separately for DYSGU VCF and DeepVariant VCF** 
- See `run_sarek_snp_vep_hg38.sh`, `run_sarek_dysgu_vep_hg38.sh`, `run_sarek_snp_vep_chm13.sh`, `run_sarek_dysgu_vep_chm13.sh`

## Merge deepvariant and dysgu callsets
Run `merge_dv_dysgu.sh` which uses `bcftools concat` to concatenate the `deepvariant` and `dysgu` callsets, then sorts the merged vcf and removes any variants without VEP annotations using `bcftools view`

## Annotate with Genmod
To run genmod on Setonix, first split the cohort VCF file by chromosome using the following:

```
module load bcftools/1.15
cd /scratch/pawsey0933/cfolland/pangenome/vcfs
PREFIX=hprc-v1.1-mc-${GENOME}

# get chroms:
bcftools query -f '%CHROM\n' ${PREFIX}_dv_dysgu_VEP_sorted_noCSQ.vcf.gz | sort | uniq > ${PREFIX}_chroms.txt

# split by chroms (autosome and sex):
for chr in {1..22} X Y; do bcftools view -Oz -o ${PREFIX}_dv_dysgu_VEP_sorted_noCSQ_${chr}.vcf.gz ${PREFIX}_dv_dysgu_VEP_sorted_noCSQ.vcf.gz chr$chr; done
```

Running genmod on the entire VCF file will result in an OOM error. 

Annotate the chr VCF files using Genmod with `genmod.sh`:

```
for chr in {1..22} X Y ; do sbatch --export=chr=$chr genmod.sh; done
```

Once complete, compress and index the files:
```
for file in *genmod_*.vcf; do bgzip $file; tabix -p ${file}.gz; done
```

Finally, merge the individual files back to one using `concat-genmod.sh`

## Annotate VCF file with AF from control cohorts
- 3202 srGS samples from 1000 Genomes Phase 3 recalled on T2T-CHM13
- The Human Pangenome Reference Consortium (HPRC) T2T-CHM13 callset, including 44 high quality diploid human assemblies, as described in Liao et al. 2023.
- The combined HPRC and HGSVC3 T2T-CHM13 callset, including 42 HPRC assemblies + 65 HGVCS3, as described in Logsdon et al. 2024
- 76,156 srGS aligned to GRCh38 from gnomAD v3.1.2 and lifted over to T2T-CHM13


