#!/bin/bash -l

#SBATCH --job-name=families_grch38
#SBATCH --account=pawsey0933
#SBATCH --partition=work
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --nodes=1
#SBATCH --time=12:00:00
#SBATCH --mail-user=chiara.folland@perkins.org.au
#SBATCH --mail-type=END
#SBATCH --error=%j.%x.err
#SBATCH --output=%j.%x.out
#SBATCH --export=ALL

# Load modules
module load vcftools/0.1.16--pl5321hd03093a_7
module load bcftools/1.15--haf5b3da_0

cd /scratch/pawsey0933/cfolland/pangenome/vcfs/families

GENOME=grch38
PREFIX=hprc-v1.1-mc-$GENOME
PED=/software/projects/pawsey0933/pangenome/genmod/trios.ped
INPUT_VCF=/scratch/pawsey0933/cfolland/pangenome/vcfs/qc/${PREFIX}_annotated_filtered.vcf.gz 

for family in $(awk '{print $1}' $PED | sort -nu ); do
    mkdir -p $family
    cd $family
    samples=$(awk -v var="$family" '$1==var {print $2}' $PED | tr '\n' ',')
    echo "Processing family: $family with samples: $samples"
    
    # Extract family-specific samples
    bcftools view --threads 6 -s ${samples%,*} -c1 -Ov -o ${family}_${PREFIX}.vcf $INPUT_VCF
    bgzip -f ${family}_${PREFIX}.vcf
    tabix -p vcf ${family}_${PREFIX}.vcf.gz
    
    # Filter variants for each group
      for filter in AR AD; do
        filt="^${family}:.*${filter}.*"
        echo "Filtering for: $filt"
        
        # Apply filter with bcftools
        bcftools view --threads 6 -i "INFO/GeneticModels~'${filt}'" -Ov -o ${family}_${filter}_${PREFIX}.vcf ${family}_${PREFIX}.vcf.gz
        bgzip ${family}_${filter}_${PREFIX}.vcf
        tabix -p vcf ${family}_${filter}_${PREFIX}.vcf.gz
        
        # Check for output
        if [[ -f ${family}_${filter}_${PREFIX}.vcf ]]; then
            echo "Filtered VCF created: ${family}_${filter}_${PREFIX}.vcf"
        else
            echo "Warning: No variants found for ${filter} in family $family"
        fi
    done
    cd ..
done
