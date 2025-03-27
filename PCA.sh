#!/bin/bash
#$ -cwd           # Set the working directory for the job to the current directory
#$ -pe smp 1      # Request 1GB per core   
#$ -l h_rt=1:0:0# Request 24 hours runtime
#$ -l h_vmem=1G # Request 1GB per core

echo "Script started at: $(date)"

# Loading necessary modules
module load plink/2.00a6LM

# Specifying input and output pathway directories
VCF_FILE=/data/SBBS-FumagalliLab/SWAsia/Retrotransposons/HGDP/hgdp_wgs.20190516.full.chr21.vcf.gz
RESULTS_DIR=/data/home/bty647/output

# Step 1: Linkage Pruning
plink2 --vcf $VCF_FILE --set-all-var-ids @:# \ # Assign unique variant IDs based on chromosome and position
  --indep-pairwise 50 5 0.1 \ # Perform LD pruning with a window size of 50 SNPs, step size of 5, and an r² threshold of 0.1
  --max-alleles 2 \ # Filter out non-bi-allelic variants (only keep SNPs with two alleles)
  --make-bed \ # Convert the dataset into PLINK binary format
  --out $RESULTS_DIR/chr21_pruned

# Step 3: PCA Analysis (on LD-pruned dataset)
plink2 --bfile $RESULTS_DIR/chr21_pruned \
  --extract $RESULTS_DIR/chr21_pruned.prune.in \ # Select only the uncorrelated SNPs (pruned variants) for PCA
  --make-bed \
  --pca \ # Perform PCA
  --out $RESULTS_DIR/chr21_pca_pruned

## MAF Filtering ##  

# Step 2: MAF Filtering (on LD-pruned dataset) for three thresholds
#MAF 0.05
plink2 --bfile $RESULTS_DIR/chr21_pruned \ 
  --maf 0.05 \ # Filter out SNPs with a minor allele frequency < 5%
  --make-bed \ 
  --out $RESULTS_DIR/chr21_maf_0.05
 #MAF 0.01
plink2 --bfile $RESULTS_DIR/chr21_pruned \ 
  --maf 0.01 \ # Filter out SNPs with a minor allele frequency < 1%
  --make-bed \ 
  --out $RESULTS_DIR/chr21_maf_0.01 
#MAF 0.1
plink2 --bfile $RESULTS_DIR/chr21_pruned \ 
  --maf 0.1 \ # Filter out SNPs with a minor allele frequency < 10%
  --make-bed \ 
  --out $RESULTS_DIR/chr21_maf_0.1


# Step 3: PCA Analysis (on MAF-filtered dataset)
# PCA for MAF 0.05
plink2 --bfile $RESULTS_DIR/chr21_maf_0.05 \
  --pca \
  --out $RESULTS_DIR/chr21_pca_0.05
# PCA for MAF 0.01
plink2 --bfile $RESULTS_DIR/chr21_maf_0.01 \
  --pca \
  --out $RESULTS_DIR/chr21_pca_0.01
# PCA for MAF 0.1
plink2 --bfile $RESULTS_DIR/chr21_maf_0.1 \
  --pca \
  --out $RESULTS_DIR/chr21_pca_0.1




echo "Script ended at: $(date)"
