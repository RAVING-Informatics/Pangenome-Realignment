##Run this script to prepare necessary input index files for the vg_snakemake workflow.

#!/bin/bash -l 
#SBATCH --job-name=index_pangenome
#SBATCH --account=pawsey0933
#SBATCH --partition=work
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=220G
#SBATCH --nodes=1
#SBATCH --time=6:00:00
#SBATCH --mail-user=chiara.folland@perkins.org.au
#SBATCH --mail-type=END
#SBATCH --error=%j.%x.err
#SBATCH --output=%j.%x.out

cd /scratch/pawsey0933/cfolland/vg_snakemake/results/pg/

/software/projects/pawsey0933/pangenome/vg/vg index -b /scratch/pawsey0933/cfolland/vg_snakemake/results/pg/temp -t 4 -j hgsvc3-hprc-2024-02-23-mc-chm13.dist --no-nested-distance hgsvc3-hprc-2024-02-23-mc-chm13.gbz
/software/projects/pawsey0933/pangenome/vg/vg gbwt -p --num-threads 16 -r hgsvc3-hprc-2024-02-23-mc-chm13.ri -Z hgsvc3-hprc-2024-02-23-mc-chm13.gbz
/software/projects/pawsey0933/pangenome/vg/vg haplotypes -v 2 -t 16 -H hgsvc3-hprc-2024-02-23-mc-chm13.hapl hgsvc3-hprc-2024-02-23-mc-chm13.gbz
