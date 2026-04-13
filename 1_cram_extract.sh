#!/bin/sh

#SBATCH --job-name=WGS_Genestep_Extracting
#SBATCH --time=20:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=3G
#SBATCH --output=/vast/projects/Epilepsy_Metabolites/data/WGS_SNP/GENESTEPS_cohort/slurm_log/%x-%j.log
#SBATCH --error=/vast/projects/Epilepsy_Metabolites/data/WGS_SNP/GENESTEPS_cohort/slurm_log/%x-%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=le.c@wehi.edu.au
#SBATCH --array=1-298


# Created: 17/09/2025
# Last update: 14/03/2026
# Chris Le
# Slurm sbatch script to extract SNPs from WGS CRAM file

#$$$ STEP 0: Change --array= 1-#. Repace # with number of .bam file in the cohort

#### DO NOT ALTER
export ref_dir="/stornext/Bioinf/data/lab_bahlo/projects/epilepsy/hg38/reference/fasta/Homo_sapiens_assembly38.fasta" # Position Reference 
export bim_dir="/vast/projects/Epilepsy_Metabolites/scripts/Epi_Met_WGS/v5_merged_cohort_600k_snp.bim"  # ~600k SNP position, inc chrX (not Y) & 1447 lead SNP (n= 585,410)
####

#$$$ STEP 1: Add dir to Cohort's bam AND gvcf output
# Hint: /stornext/Bioinf/data/lab_bahlo/projects/epilepsy/hg38/cohorts/gene_steps/cram
export cram_dir="/stornext/Bioinf/data/lab_bahlo/projects/epilepsy/hg38/cohorts/gene_steps/cram"
export gvcf_dir="/vast/projects/Epilepsy_Metabolites/data/WGS_SNP/GENESTEPS_cohort/1_individual_vcf"


module load bcftools

#$$$ STEP 2: Run the chunk - get dir to each bam file
# echo "cram_files=("
# printf '    "%s"\n' "$cram_dir"/*.cram
# echo ")"


#$$$ STEP 3: Copy the output from STEP 2 into below bame_files variable
# cram_files=(
#   # "/stornext/Bioinf/data/lab_bahlo/projects/epilepsy/hg38/cohorts/gene_steps/cram/21W002777-FAM001990.cram"
# )

cram_files=(
    "/stornext/Bioinf/data/lab_bahlo/projects/epilepsy/hg38/cohorts/gene_steps/cram/21W002781-FAM001990.cram"
    "/stornext/Bioinf/data/lab_bahlo/projects/epilepsy/hg38/cohorts/gene_steps/cram/21W002786-FAM002000.cram"

    #paste all cram file to extract here

)

#### DO NOT ALTER
cram_file=${cram_files[$SLURM_ARRAY_TASK_ID-1]}
sample_id=$(basename "$cram_file" .cram)
output_file="$gvcf_dir/${sample_id}.gvcf.gz"
#####


# Run bcftools
module load bcftools

bcftools mpileup --threads 1 -a FORMAT/DP -Ou -f $ref_dir -R $bim_dir $cram_file | \
bcftools call -m --gvcf 1 -Ou | \
bcftools view -Oz --write-index=tbi -o "$output_file"







