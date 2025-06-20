Annotate HPRCv1.1-aligned variants using VEP as part of nf-core/sarek

1) Setup VEP for both chm13 and grch38 data
- Download cache for grch38 data, available [here](https://ftp.ensembl.org/pub/release-114/variation/indexed_vep_cache/homo_sapiens_vep_114_GRCh38.tar.gz)
- Download cache for chm13 data, available [here](https://ftp.ensembl.org/pub/rapid-release/species/Homo_sapiens/GCA_009914755.4/ensembl/variation/2022_10/indexed_vep_cache/Homo_sapiens-GCA_009914755.4-2022_10.tar.gz)
- Download grch38 reference genome, available [here](https://storage.googleapis.com/gcp-public-data--broad-references/hg38/v0/dragen_reference/Homo_sapiens_assembly38_masked.fasta)
- Download chm13 reference genome, available [here](https://storage.googleapis.com/gcp-public-data--broad-references/t2t/v2/chm13v2.0.maskedY.rCRS.EBV.fasta)

2) Run VEP separately for DYSGU VCF and DeepVariant VCF
- See `run_sarek_snp_vep_hg38.sh`, `run_sarek_dysgu_vep_hg38.sh`, `run_sarek_snp_vep_chm13.sh`, `run_sarek_dysgu_vep_chm13.sh`
