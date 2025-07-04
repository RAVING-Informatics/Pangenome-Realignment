#!/bin/bash -l

#SBATCH --job-name=bcftools_stats
#SBATCH --account=pawsey0933
#SBATCH --partition=work
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
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
REF=/scratch/pawsey0933/cfolland/benchmark/refs/hprc-v1.1-mc-$GENOME.ref.fa
INPUT_DIR=/scratch/pawsey0933/cfolland/benchmark/vcfs/deepvariant/pangenome/individual
OUTPUT_DIR=/scratch/pawsey0933/cfolland/benchmark/output/pangenome/bcftools_stats/individual/

ls $INPUT_DIR | grep 'vcf' | grep -v 'tbi' | while read -r file ; do
    basename=${file%%.*}
    echo "Calculating bcftools stats for $basename"
    VCF=${basename}.hprc-v1.1-mc-${GENOME}.surj_realn.snv_indels.g.vcf.gz 
    OUTPUT=$OUTPUT_DIR/${basename}.hprc-v1.1-mc-${GENOME}.surj_realn.snv_indels.g.bcftools_stats.txt
    bcftools stats $INPUT_DIR/$VCF > $OUTPUT
done
