#!/bin/bash

#SBATCH --job-name=ss_build
#SBATCH --array=1-4         # 4 jobs: 2 measures x 2 hemispheres
#SBATCH --partition=rome
#SBATCH --cpus-per-task=32
#SBATCH --time=0-01:00:00
#SBATCH --output=0.build_ss.log

# =============================================================================
# Create one supersubject matrix to use in all analyses

# Source paths and their corresponding dataset names
# declare -A SOURCES=(
  # ["mega"]="/gpfs/work2/0/einf1049/data/mega_analysis/qdecr"
  # ["genr"]="/projects/0/einf1049/data/GenR_MRI/bids/derivatives/freesurfer/6.0.0/qdecr"
  # ["abcd"]="/projects/0/einf1049/data/abcd/rel4.0/bids/derivatives/freesurfer/6.0.0/untar"
# )

# Note: "mega" contains all the data needed for all analyses, so I will make one
#       supersubject matrix to subset

export SUBJ_DIR="/gpfs/work2/0/einf1049/data/mega_analysis/qdecr"

# Destination folder
export SS_DIR="/projects/0/einf1049/scratch/sdefina/annet_attention/data/ss"
mkdir -p "$SS_DIR"

# Load necessary modules -----------------------------------------------------
module purge
module load 2024
# module load GCCcore/13.3.0
module load R/4.4.2-gfbf-2024a

# Other available r distributions (module spider R)
# R/4.2.1-foss-2022a
# R/4.3.2-gfbf-2023a

# Avoid nested impolicit parallelism (that slows things down) ----------------
export OPENBLAS_NUM_THREADS=1
export OMP_NUM_THREADS=1
export MKL_NUM_THREADS=1
export VECLIB_MAXIMUM_THREADS=1
export NUMEXPR_NUM_THREADS=1

Rscript 0.build_ss.R $SUBJ_DIR $SS_DIR
