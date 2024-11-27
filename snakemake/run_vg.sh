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
snakemake -s ./workflow/Snakefile --configfile ./config/config.hprc.yaml --slurm --profile slurm_vg --use-singularity -p all
