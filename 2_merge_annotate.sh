#!/bin/sh

#SBATCH --job-name=WGS_Genestep_merging
#SBATCH --time=20:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=100G
#SBATCH --output=/vast/projects/Epilepsy_Metabolites/data/WGS_SNP/GENESTEPS_cohort/slurm_log/%x-%j.log
#SBATCH --error=/vast/projects/Epilepsy_Metabolites/data/WGS_SNP/GENESTEPS_cohort/slurm_log/%x-%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=le.c@wehi.edu.au
#SBATCH --array=1

# Created: 15/03/2026
# Chris Le
# Merge multiple gvcf.gz files into one

export dbsnp_file="/stornext/Bioinf/data/lab_bahlo/ref_db/human/hg38/GATK/vcf/dbsnp_146.hg38.vcf.gz"
export gvcf_dir="/vast/projects/Epilepsy_Metabolites/data/WGS_SNP/GENESTEPS_cohort/1_individual_vcf"
export merged_vcf="/vast/projects/Epilepsy_Metabolites/data/WGS_SNP/GENESTEPS_cohort/2_multisample_vcf"
export plink_dir="/vast/projects/Epilepsy_Metabolites/data/WGS_SNP/GENESTEPS_cohort/3_plink"



module load bcftools


# Need to create merged gvcf --> make into vcf --> Annotate ??


# Step 1: Merged all gvcf.gz files into one 
find $gvcf_dir -name "*.gvcf.gz" |\
    xargs bcftools merge --no-version --threads 1 --filter-logic x |\
    bcftools annotate --set-id +'%CHROM\_%POS' |\
    bcftools view --no-version --threads 1 --no-update --output-type z --write-index=tbi --output $merged_vcf/genesteps_multisamples_hg38.vcf.gz


# Step 2: Annotate SNPs with rsID
bcftools annotate --no-version --threads 4 -a "$dbsnp_file" -c ID $merged_vcf/genesteps_multisamples_hg38.vcf.gz | \
  bcftools annotate --no-version --threads 4 --set-id +'%CHROM\_%POS' | \
  bcftools view --no-version --threads 4 --output-type z --write-index=tbi --output $merged_vcf/genesteps_multisamples_annotated_hg38.vcf.gz



# Check if file is truncated 
# [E::vcf_parse_format_check7] Number of columns at chr9:138121868 does not match the number of samples (83 vs 299)
# Error: VCF parse error
# [E::vcf_parse_format_check7] Number of columns at chr9:137967716 does not match the number of samples (277 vs 299)


# Step 3: Convert to vcf to plink
module load plink

plink \
    --vcf "$merged_vcf/genesteps_multisamples_annotated_hg38.vcf.gz" \
    --make-bed \
    --keep-allele-order \
    --allow-no-sex \
    --out "$plink_dir/genesteps_plink_annotated_hg38"


# Need to merge to control before this


# Step xxx: Convert plink to .raw
plink \
    --bfile "$plink_dir/genesteps_plink_annotated_hg38" \
    --recode A \
    --keep-allele-order \
    --out "$plink_dir/genesteps_plink_20260316.metab" #Generate additive .raw file with genotype counts






  
  
