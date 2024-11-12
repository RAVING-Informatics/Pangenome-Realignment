#Run this script to preprepare the index and dict files
#hprc-v1.0-mc-grch38_extracted-ref.fa is sourced from task extractReference, but can be sourced by running vg paths

#!/bin/bash

samtools faidx hprc-v1.0-mc-grch38_extracted-ref.fa

conda activate picard

picard CreateSequenceDictionary \
  -R hprc-v1.0-mc-grch38_extracted-ref.fa \
  -O hprc-v1.0-mc-grch38_extracted-ref.dict
