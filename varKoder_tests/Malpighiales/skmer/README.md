#Skmer

Scripts used to run skmer

* `01_create_dirs.sh` creates directories and symlinks to reads produced by varKoder. These have been cleaned with fastp, deduplicated and split into standardized amounts of data.

* `02_run_skmer_xval.sh` does the cross validation by running references with a set input data amount. This is controlled by the array ID given to slurm when running it (from 0 to 8). Queries are done for all input sizes available for a sample. 
