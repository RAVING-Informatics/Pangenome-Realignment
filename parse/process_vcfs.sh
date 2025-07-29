#!/bin/bash -l

#SBATCH --job-name=parse
#SBATCH --account=pawsey0933
#SBATCH --partition=work
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=100G
#SBATCH --nodes=1
#SBATCH --time=2:00:00
#SBATCH --mail-user=chiara.folland@perkins.org.au
#SBATCH --mail-type=END
#SBATCH --error=%j.%x.err
#SBATCH --output=%j.%x.out
#SBATCH --export=ALL

module load python/3.11.6
module load py-pandas/1.5.3

# Directory containing the VCF subdirectories
INPUT_DIR="/scratch/pawsey0933/cfolland/pangenome/vcfs/families/"

# Directory where the output files will be stored
OUTPUT_DIR="/scratch/pawsey0933/cfolland/pangenome/vcfs/families_parsed"

# Path to the Python script
PARSE_SCRIPT="/software/projects/pawsey0933/pangenome/parse/parse-line.py"

# Output format (e.g., tsv or csv)
OUTPUT_FORMAT="csv"

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Loop through each subdirectory
find "$INPUT_DIR" -type f \( -name "*.vcf" -o -name "*.vcf.gz" \) | while IFS= read -r VCF_FILE; do
    # Get the relative path of the VCF file (relative to INPUT_DIR)
    RELATIVE_PATH=$(realpath --relative-to="$INPUT_DIR" "$(dirname "$VCF_FILE")")
    
    # Create the corresponding subdirectory in the output directory
    OUTPUT_SUBDIR="$OUTPUT_DIR/$RELATIVE_PATH"
    mkdir -p "$OUTPUT_SUBDIR"
    
    # Get the prefix of the VCF file (without extension)
    PREFIX=$(basename "$VCF_FILE" | sed -E 's/\.(vcf|vcf\.gz)$//')
    
    # Construct the output file path
    OUTPUT_FILE="$OUTPUT_SUBDIR/${PREFIX}_parsed.$OUTPUT_FORMAT"
    echo "Processing file: $VCF_FILE -> $OUTPUT_FILE"
    python "$PARSE_SCRIPT" "$VCF_FILE" "$OUTPUT_FILE" --output_format "$OUTPUT_FORMAT"
done

