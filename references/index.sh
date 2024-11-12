#Run this script to preprepare the index and dict files

#!/bin/bash

samtools faidx hprc-v1.0-mc-grch38_extracted-ref.fa

conda activate picard

picard CreateSequenceDictionary \
  -R hprc-v1.0-mc-grch38_extracted-ref.fa \
  -O hprc-v1.0-mc-grch38_extracted-ref.dict
