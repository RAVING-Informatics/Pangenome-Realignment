1. Clone github repository into /scratch
```
git clone https://github.com/vgteam/vg_snakemake.git
```
2. Download necessary files using `download.sh` script.

3. Edit the workflow file `common.smk` under `./workflow/rules/` to update the docker file:
```
docker_imgs['gatk_bedtools'] = "docker://docker.io/chiarafolland/custom-gatk-bedtools-glibc@sha256:dd506b1ca208525d0480cf712b4a89c7e4094f87a13951becf222d153c24d55f"
```

4. Edit the configuration files `config.hprc.yaml` and `sample_info.tsv`
5. Create a snakemake slurm configuration in `$HOME` dir `/home/cfolland/.config/snakemake/`: `slurm_vg_config.yaml`
6. Execute `run_vg.sh`
