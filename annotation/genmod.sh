#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH -c 2
#SBATCH --job-name=genmod
#SBATCH --partition=work
#SBATCH --account=pawsey0933
#SBATCH --mem=60G
#SBATCH --time=03:00:00
#SBATCH --mail-user=gavin.monahan@perkins.org.au
#SBATCH --mail-type=END
#SBATCH --error=%j.%x.err
#SBATCH --output=%j.%x.out
#SBATCH --export=ALL

input_dir=/scratch/pawsey0933/cfolland/pangenome/vcfs
ped=/software/projects/pawsey0933/pangenome/genmod/trios.ped
GENOME=grch38
PREFIX=hprc-v1.1-mc-${GENOME}

conda activate genmod

genmod models --vep -p 2 -f $ped $input_dir/${PREFIX}_dv_dysgu_VEP_sorted_noCSQ_${chr}.vcf.gz > $input_dir/${PREFIX}_dv_dysgu_VEP_genmod_${chr}.vcf
