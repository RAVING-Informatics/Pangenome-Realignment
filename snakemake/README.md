## Batch 1 - HPRCv1.1

1. Create a conda environment within snakemake v7.32.4 installed:
```
conda create -c conda-forge -c bioconda -n snakemake snakemake=7.32.4
```
2. Clone github repository into /scratch
```
git clone https://github.com/vgteam/vg_snakemake.git
```
3. Download necessary reference files:
```
wget https://s3-us-west-2.amazonaws.com/human-pangenomics/pangenomes/freeze/freeze1/minigraph-cactus/hprc-v1.1-mc-grch38/hprc-v1.1-mc-grch38.gbz
wget https://s3-us-west-2.amazonaws.com/human-pangenomics/pangenomes/freeze/freeze1/minigraph-cactus/hprc-v1.1-mc-grch38/hprc-v1.1-mc-grch38.hapl
wget https://s3-us-west-2.amazonaws.com/human-pangenomics/pangenomes/freeze/freeze1/minigraph-cactus/hprc-v1.1-mc-chm13/hprc-v1.1-mc-chm13.gbz
wget https://s3-us-west-2.amazonaws.com/human-pangenomics/pangenomes/freeze/freeze1/minigraph-cactus/hprc-v1.1-mc-chm13/hprc-v1.1-mc-chm13.hapl
```

4. Edit the workflow file `common.smk` under `./workflow/rules/` to update the docker file:
```
docker_imgs['gatk_bedtools'] = "docker://docker.io/chiarafolland/custom-gatk-bedtools-glibc@sha256:dd506b1ca208525d0480cf712b4a89c7e4094f87a13951becf222d153c24d55f"
```

5. Edit the configuration files `config.hprc1.1.yaml` and `sample_info_batch1.tsv`
6. Create a snakemake slurm configuration in `$HOME` dir `/home/cfolland/.config/snakemake/`: `slurm_hprcv1.1_config.yaml`
7. Execute `run_vg_v1.1.sh`


## Batch 2 - HPRCv2.0

1. Create a conda/mamba environment with snakemake v9.14.3 installed:
```
#create conda env
conda create -c conda-forge -c bioconda -c nodefaults -n snakemake snakemake=9.14.3
#fix issues with config incompatibilities
mamba install -c bioconda snakemake-executor-plugin-cluster-generic
```
2. Clone github repository into /scratch
```
git clone https://github.com/vgteam/vg_snakemake.git
```
3. Download necessary reference files:
```
wget https://human-pangenomics.s3.amazonaws.com/pangenomes/freeze/release2/minigraph-cactus/hprc-v2.0-mc-grch38.gbz
wget https://human-pangenomics.s3.amazonaws.com/pangenomes/freeze/release2/minigraph-cactus/hprc-v2.0-mc-grch38.hapl
```
4. Edit the workflow file `common.smk` under `./workflow/rules/` to update the docker file:
```
docker_imgs['gatk_bedtools'] = "docker://docker.io/chiarafolland/custom-gatk-bedtools-glibc@sha256:dd506b1ca208525d0480cf712b4a89c7e4094f87a13951becf222d153c24d55f"
```
5. Edit the configuration files `config.hprc1.1.yaml` and `sample_info_batch1.tsv`
6. Create a snakemake slurm configuration in `$HOME` dir `/home/cfolland/.config/snakemake/`: `slurm_hprcv1-1_config.yaml`
7. Execute `run_vg_v1.1.sh
