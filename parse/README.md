# Parse cohort VCF for analysis

## 1) Subset cohort VCF into individual family VCFs
Use script `families.sh` to generate family-specific VCF files with AD and AR filters.

## 2) Subset family VCF into VCF containing variants only in affecteds
Use script `affected.sh` to generate a VCF with variants that are either heterozygous (1/0, 0/1) or homozygous alt (1/1) in affected individuals. Unaffected individuals can have any genotype.

## 3) Generate tsv/csv files of family VCFs for easy analysing
Use script `process_vcfs.sh` which runs the python parsing script `parse_line.py` on each VCF in each family.
Ensure the VCFs are nested in a directory structure where each family has their own subdirectory. 
This should already be the case if you have run `families.sh` first. 

```
(base) cfolland@setonix-02[families]$ ls
10105  11123  11308  15043  16337  16566  17959  19992  19997  20003  2357  6188  6815  8037  8600  9009  9885
```
