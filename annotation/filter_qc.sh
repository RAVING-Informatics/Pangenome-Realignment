#!/bin/bash -l

#SBATCH --job-name=filter_qc
#SBATCH --account=pawsey0933
#SBATCH --partition=work
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --nodes=1
#SBATCH --time=1:00:00
#SBATCH --mail-user=chiara.folland@perkins.org.au
#SBATCH --mail-type=END
#SBATCH --error=%j.%x.err
#SBATCH --output=%j.%x.out
#SBATCH --export=ALL

#load modules
module load vcftools/0.1.16--pl5321hd03093a_7
module load bcftools/1.15--haf5b3da_0

input=/scratch/pawsey0933/cfolland/pangenome/vcfs/genmod
output=/scratch/pawsey0933/cfolland/pangenome/vcfs/qc
GENOME=grch38
PREFIX=hprc-v1.1-mc-$GENOME
ref=/scratch/pawsey0933/cfolland/benchmark/refs/hprc-v1.1-mc-${GENOME}.ref.fa

#convert from multiallelic to bi-allelic
bcftools norm -m -any --check-ref skip -f $ref -o $output/${PREFIX}_dv_dysgu_VEP_genmod_biallelic.vcf.gz $input/${PREFIX}_dv_dysgu_VEP_genmod.vcf.gz
tabix -p vcf $output/${PREFIX}_dv_dysgu_VEP_genmod_biallelic.vcf.gz

#Filter based on qc 
bcftools view -v snps,indels $output/${PREFIX}_dv_dysgu_VEP_genmod_biallelic.vcf.gz | bcftools filter -e 'INFO/SVMETHOD == "DYSGUv1.7.0"' -Oz -o $output/${PREFIX}_VEP_genmod_biallelic_dv_qc.vcf.gz
bcftools view -v other,indels $output/${PREFIX}_dv_dysgu_VEP_genmod_biallelic.vcf.gz | bcftools filter -i 'INFO/SVMETHOD == "DYSGUv1.7.0"' | bcftools view -i 'FILTER="PASS"' -Oz -o $output/${PREFIX}_VEP_genmod_biallelic_dysgu_qc.vcf.gz

#tabix
tabix -p vcf $output/${PREFIX}_VEP_genmod_biallelic_dysgu_qc.vcf.gz
tabix -p vcf $output/${PREFIX}_VEP_genmod_biallelic_dv_qc.vcf.gz

#concatenate files back
bcftools concat -a $output/${PREFIX}_VEP_genmod_biallelic_dv_qc.vcf.gz $output/${PREFIX}_VEP_genmod_biallelic_dysgu_qc.vcf.gz -Oz -o $output/${PREFIX}_annotated_filtered.vcf.gz

#Index the filtered VCF
tabix -p vcf $output/${PREFIX}_annotated_filtered.vcf.gz
