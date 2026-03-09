#!/bin/bash -l

#SBATCH --job-name=run_vg_v1.1
#SBATCH --account=pawsey0933
#SBATCH --partition=work
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --nodes=1
#SBATCH --time=24:00:00
#SBATCH --mail-user=chiara.folland@perkins.org.au
#SBATCH --mail-type=END
#SBATCH --error=%j.%x.err
#SBATCH --output=%j.%x.out
#SBATCH --export=ALL

module load singularity/4.1.0-slurm 

#Load conda env
source /software/projects/pawsey0933/cfolland/miniconda3/etc/profile.d/conda.sh
conda activate /software/projects/pawsey0933/cfolland/miniconda3/envs/drop_env_133

#Change cache dir
export XDG_CACHE_HOME=/scratch/pawsey0933/cfolland/vg_snakemake/.cache

#Change to working dir
cd /scratch/pawsey0933/cfolland/vg_snakemake/

#Unlock working directory
snakemake -s ./workflow/Snakefile --cores 1 --unlock

#Run snakemake
snakemake -s ./workflow/Snakefile --configfile ./config/config.hprcv1.1.yaml --slurm --profile slurm_vg --use-singularity -p all
