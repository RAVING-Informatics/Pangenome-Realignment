#!/bin/bash -l

#SBATCH --job-name=bcftools_stats
#SBATCH --account=pawsey0933
#SBATCH --partition=work
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=16G
#SBATCH --nodes=1
#SBATCH --time=1:00:00
#SBATCH --mail-user=chiara.folland@perkins.org.au
#SBATCH --mail-type=END
#SBATCH --error=%j.%x.err
#SBATCH --output=%j.%x.out
#SBATCH --export=NONE

#load modules
module load bcftools/1.15--haf5b3da_0

#Define variables
GENOME=chm13
#grch38
REF=/scratch/pawsey0933/cfolland/benchmark/refs/hprc-v1.1-mc-$GENOME.ref.fa
INPUT_DIR=/scratch/pawsey0933/cfolland/benchmark/vcfs/deepvariant/pangenome/cohort/
OUTPUT_DIR=/scratch/pawsey0933/cfolland/benchmark/output/pangenome/bcftools_stats/cohort/
PREFIX=hprc-v1.1-mc-${GENOME}_dv_glnexus 
VCF=$PREFIX.vcf.gz

echo "Calculating bcftools stats for $PREFIX"
OUTPUT=$OUTPUT_DIR/${PREFIX}.bcftools_stats.txt
bcftools stats $INPUT_DIR/$VCF > $OUTPUT
