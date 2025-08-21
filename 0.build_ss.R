# Load (latest) verywise package
local_lib <- "/gpfs/home6/sdefina/R/x86_64-pc-linux-gnu-library/4.4"
.libPaths(c(local_lib, .libPaths()))

# devtools::install_github("SereDef/verywise", lib=local_lib)

library(verywise)

# Arguments --------------------------------------------------------
n_cores <- as.integer(Sys.getenv("SLURM_CPUS_PER_TASK"))
bigparallelr::assert_cores(n_cores)

args <- commandArgs(trailingOnly = TRUE)
subj_dir <- args[1]
supsubj_dir <- args[2]

hemi <- c("lh", "rh")
measure <- c("area", "thickness")

job_grid <- expand.grid(data.frame(hemi, measure), stringsAsFactors = FALSE)

params <- job_grid[Sys.getenv("SLURM_ARRAY_TASK_ID"), ]

hemi <- params$hemi
measure <- params$measure

fs_template <- "fsaverage" # default
error_cutoff <- 20         # default

# Read phenotype file for the fodler list ------------------------
pheno_file <- file.path(dirname(supsubj_dir), "mega.rds")
pheno_mids <- readRDS(pheno_file)
# note: there should be no missings in folder id column
pheno <- mice::complete(pheno_mids, action=0)

# ----------------------------------------------------------------
start.time <- Sys.time()

ss <- build_supersubject(
                  subj_dir = subj_dir,
                  folder_ids = pheno[, 'folder'],
                  supsubj_dir = supsubj_dir,
                  measure = measure,
                  hemi = hemi,
                  fs_template = fs_template,
                  n_cores = n_cores,
                  error_cutoff = error_cutoff,
                  save_rds = TRUE,
                  verbose = TRUE)

end.time <- Sys.time()

cat("\nStart time: ", as.character(start.time), 
    "\nEnd time: ", as.character(end.time),
    "\nElapsed: ", end.time - start.time, "\n")
