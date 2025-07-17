#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH -c 6                          
#SBATCH --job-name=concat_genmod
#SBATCH --partition=work
#SBATCH --account=pawsey0933
#SBATCH --mem=16G
#SBATCH --time=2:00:00
#SBATCH --mail-user=chiara.folland@perkins.org.au
#SBATCH --mail-type=END
#SBATCH --error=%j.%x.err
#SBATCH --output=%j.%x.out
#SBATCH --export=ALL

# Load modules
module load bcftools/1.15--haf5b3da_0

# Define variables
ref=grch38
outdir=/scratch/pawsey0933/cfolland/pangenome/vcfs

# Concatenate, sort and index
bcftools concat -a -Oz --threads 12 -o $outdir/hprc-v1.1-mc-${ref}_dv_dysgu_VEP_genmod.vcf.gz $outdir/hprc-v1.1-mc-${ref}_dv_dysgu_VEP_genmod_*.vcf.gz
bcftools sort -T $outdir -o $outdir/hprc-v1.1-mc-${ref}_dv_dysgu_VEP_genmod_sorted.vcf.gz $outdir/hprc-v1.1-mc-${ref}_dv_dysgu_VEP_genmod.vcf.gz
bcftools index -t $outdir/hprc-v1.1-mc-${ref}_dv_dysgu_VEP_genmod_sorted.vcf.gz
