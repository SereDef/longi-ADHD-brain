# Load (latest) verywise package
local_lib <- "/gpfs/home6/sdefina/R/x86_64-pc-linux-gnu-library/4.4"
.libPaths(c(local_lib, .libPaths()))

# devtools::install_github("SereDef/verywise", lib=local_lib)
library(verywise)

# Arguments --------------------------------------------------------
n_cores <- as.integer(Sys.getenv("SLURM_CPUS_PER_TASK"))

options(bigstatsr.check.parallel.blas = FALSE)

bigparallelr::assert_cores(n_cores)

args <- commandArgs(trailingOnly = TRUE)
data_dir <- args[1]
outp_dir <- args[2]

task_n <- Sys.getenv("SLURM_ARRAY_TASK_ID")

hemi <- c("lh", "rh")
measure <- c("area", "thickness")
dataset <- c("genr", "abcd", "mega")
modeltype <- c("add", "ageint")

job_grid <- expand.grid(hemi, measure, dataset, modeltype, stringsAsFactors = FALSE)

params <- job_grid[task_n, ]

hemi <- params$Var1
measure <- params$Var2
dataset <- params$Var3
modeltype <- params$Var4

# Formula 
age_interct <- ifelse(modeltype == "add", "+ age + sex", 
                                          "* age + sex + sex:age")
                                          
random_term <- ifelse(dataset == "genr", "(1|idc)", 
                                         "(1|id) + (1|site)")

model_formula <- as.formula(paste0("vw_", measure, " ~ att ", age_interct,
                                   " + ethn + educm + psych_m + tobacco + age_m + ", random_term))

# Directories
subj_dir <- file.path(data_dir, "ss")

model_outp_dir <- file.path(outp_dir, paste(dataset, modeltype, sep="_"))
# I create it already so I can put the log there 
dir.create(model_outp_dir, recursive = TRUE, showWarnings = FALSE)

# Phenotype file
pheno_file <- file.path(data_dir, paste0(dataset, ".rds"))


frees_home <- "/home/genr/software/freesurfer/6.0.0/"

fs_template <- "fsaverage" # default
chunk_size <- 765         # based on 96 cores and ~ 145.000 to 145.500 vertices per hemi
error_cutoff <- 20         # default

# Redirect std out/err to the corresponding output directory 
# log_file <- file(file.path(model_outp_dir, "pipeline.log"), open = "wt")
# sink(log_file)
# sink(log_file, type="message")

# Main analysis ----------------------------------------------------
# Main analysis -----------------------------------------------------------
message(
    "============================================================\n",
    "--- (", task_n, ") ", hemi, " ", measure, " - ",  dataset, " - ", modeltype, " ---",
  "\n============================================================\n")


start.time <- Sys.time()

out <- run_vw_lmm(formula = model_formula,
                  pheno = pheno_file,
                  subj_dir = subj_dir,
                  outp_dir = model_outp_dir,
                  hemi = hemi,
                  fs_template = fs_template,
                  apply_cortical_mask = TRUE,
                  folder_id = 'folder',
                  tolerate_surf_not_found = error_cutoff,
                  use_model_template = TRUE,
                  weights = 'weights',
                  lmm_control = lme4::lmerControl(),
                  seed = 3108,
                  n_cores = n_cores,
                  chunk_size = chunk_size,
                  FS_HOME = frees_home,
                  save_ss = FALSE,
                  verbose = TRUE)

end.time <- Sys.time()

cat("\nStart time: ", as.character(start.time), 
    "\nEnd time: ", as.character(end.time),
    "\nElapsed: ", end.time - start.time, "\n")

# sink()
# sink(type="message")
# close(log_file)