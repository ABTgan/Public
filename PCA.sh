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

# Step 2: PCA Analysis
plink2 --bfile $RESULTS_DIR/chr21_pruned \
  --extract $RESULTS_DIR/chr21_pruned.prune.in \ # Select only the uncorrelated SNPs (pruned variants) for PCA
  --make-bed \
  --pca \
  --out $RESULTS_DIR/chr21_pca_results

echo "Script ended at: $(date)"
