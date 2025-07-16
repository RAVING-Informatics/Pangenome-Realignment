#!/bin/bash -l

#SBATCH --job-name=clinvar_isec
#SBATCH --account=pawsey0933
#SBATCH --partition=work
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --nodes=1
#SBATCH --time=2:00:00
#SBATCH --mail-user=chiara.folland@perkins.org.au
#SBATCH --mail-type=END
#SBATCH --error=%j.%x.err
#SBATCH --output=%j.%x.out
#SBATCH --export=ALL

#load modules
module load bcftools/1.15--haf5b3da_0

GENOME=chm13
prefix=hprc-v1.1-mc-$GENOME
cohort=/scratch/pawsey0933/cfolland/benchmark/vcfs/deepvariant/pangenome/cohort/${prefix}_dv_glnexus.vcf.gz
vcf_output=/scratch/pawsey0933/cfolland/benchmark/vcfs/deepvariant/pangenome/cohort/
#clinvar=/software/projects/pawsey0933/benchmarking/clinvar/common_clinvar_ucsc_20220313.vcf.gz
clinvar=/software/projects/pawsey0933/benchmarking/clinvar/chm13v2.0_ClinVar20220313.vcf.gz

bcftools isec -p $vcf_output/isec_output_$GENOME -n=2 $cohort $clinvar
