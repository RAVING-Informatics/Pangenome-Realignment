1. Clone github repository into /scratch
```
git clone https://github.com/vgteam/vg_snakemake.git
```
2. Download necessary files using `download.sh` script.
3. Edit the configuration files `config.hprc.yaml` and `sample_info.tsv`
4. Create a snakemake slurm configuration in `$HOME` dir `/home/cfolland/.config/snakemake/`: `slurm_vg_config.yaml`
5. Execute `run_vg.sh`
