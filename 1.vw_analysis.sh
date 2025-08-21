#!/bin/bash

#SBATCH --job-name=vw_anal
#SBATCH --array=1-24         # 24 jobs: 2 measures x 2 hemispheres x 3 samples x 2 models
#SBATCH --partition=rome
#SBATCH --cpus-per-task=96   # NOTE R limit parallel processes = 124
#SBATCH --time=2-00:00:00
#SBATCH --output=logs/1.vw_analysis_%a.log # NOTE: redirect output from inside Rscript?
#SBATCH --error=logs/1.vw_analysis_%a.err

# =============================================================================

export PROJDIR="/projects/0/einf1049/scratch/sdefina/annet_attention"
export PROJDIR_DATA="$PROJDIR"/data
export PROJDIR_OUTP="$PROJDIR"/output


# Load necessary modules -----------------------------------------------------
module purge
module load 2024
module load R/4.4.2-gfbf-2024a

# Other available r distributions (module spider R)
# R/4.2.1-foss-2022a
# R/4.3.2-gfbf-2023a

Rscript 1.vw_analysis.R $PROJDIR_DATA $PROJDIR_OUTP
