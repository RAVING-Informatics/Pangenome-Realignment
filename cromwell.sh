#!/bin/bash

#load modules
module load singularity/4.1.0-slurm

#Define variables
wdl=/software/projects/pawsey0933/giraffe/wdl/giraffe_and_deepvariant_slurm.wdl
config=/software/projects/pawsey0933/cromwell/cromwell.conf
inputs=/software/projects/pawsey0933/giraffe/wdl/giraffe_and_deepvariant.json
jar=/software/projects/pawsey0933/cromwell/cromwell-87.jar

#change to working dir
cd /scratch/pawsey0933/cfolland/giraffe
rm -rf /scratch/pawsey0933/cfolland/giraffe/cromwell-executions
rm -rf /scratch/pawsey0933/cfolland/giraffe/cromwell-workflow-logs
rm -rf /scratch/pawsey0933/cfolland/giraffe/singularity-cache

# Run the Cromwell workflow with the specified configuration file
java -Dconfig.file=$config -jar $jar run $wdl --inputs $inputs
