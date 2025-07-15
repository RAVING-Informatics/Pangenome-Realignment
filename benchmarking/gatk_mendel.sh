#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH -c 1
#SBATCH --job-name=mendel
#SBATCH --partition=work
#SBATCH --account=pawsey0933
#SBATCH --mem=16G
#SBATCH --time=1:10:00
#SBATCH --mail-user=chiara.folland@perkins.org.au
#SBATCH --mail-type=END
#SBATCH --error=%j.%x.err
#SBATCH --output=%j.%x.out
#SBATCH --export=ALL

GENOME=chm13
prefix=hprc-v1.1-mc-$GENOME
sif=/software/projects/pawsey0933/benchmarking/mendel/gatk_latest.sif
ref=/scratch/pawsey0933/cfolland/benchmark/refs/hprc-v1.1-mc-$GENOME.ref.fa
input=/scratch/pawsey0933/cfolland/vep/annotation/glnexus/joint_variant_calling/${prefix}_VEP.ann.vcf.gz
output=/scratch/pawsey0933/cfolland/benchmark/mendel_viol/pangenome/$prefix.MVs.byFamily.table
ped=/software/projects/pawsey0933/pangenome/genmod/trios.ped

module load singularity/4.1.0-slurm

singularity exec $sif \
    gatk \
    --java-options -Xmx16G \
    VariantEval \
    -R $ref \
    -O $output \
    --eval $input \
    -no-ev -no-st --lenient \
    -ST Family \
    -EV MendelianViolationEvaluator \
    -ped $ped -pedValidationType SILENT
