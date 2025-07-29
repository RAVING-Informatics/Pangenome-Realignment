#!/bin/bash -l

#SBATCH --job-name=affected
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
module load bcftools/1.15--haf5b3da_0

dir=/scratch/pawsey0933/cfolland/pangenome/vcfs/families
GENOME=grch38
PREFIX=hprc-v1.1-mc-$GENOME
PED=/software/projects/pawsey0933/pangenome/genmod/trios.ped

for family in $(awk '{print $1}' $PED | sort -nu ); do
    mkdir -p $dir/$family
    cd $dir/$family
    echo "Processing family: $family"

    # Get affected individuals
    affected_samples=$(awk -v fam="$family" '$1==fam && $6==2 {print $2}' $PED)

    # Proceed only if affected individuals are present
    if [[ -n "$affected_samples" ]]; then
        echo "Affected samples: $affected_samples"

        # Extract header line to find sample columns
        header=$(zcat ${family}_${PREFIX}.vcf.gz | grep "^#CHROM")

        # Build awk condition for affected samples
        condition=""
        for sample in $affected_samples; do
            colnum=$(echo "$header" | tr '\t' '\n' | nl -ba | awk -v s=$sample '$2==s {print $1}')
            if [[ -n "$colnum" ]]; then
                # Add condition for this sample column
                if [[ -n "$condition" ]]; then
                    condition="$condition || \$$colnum ~ \"0/1|1/1|1/0\""
                else
                    condition="\$$colnum ~ \"0/1|1/1|1/0\""
                fi
            fi
        done

        # Run awk filtering dynamically based on affected samples
        zcat ${family}_${PREFIX}.vcf.gz | \
            awk 'BEGIN{OFS="\t"} /^#/ {print; next} '"$condition"' {print}' | \
            bgzip > ${family}_${PREFIX}_affected.vcf.gz

        tabix -p vcf ${family}_${PREFIX}_affected.vcf.gz

    else
        echo "Warning: No affected individuals found in family $family. Skipping genotype-based filtering."
    fi
done
