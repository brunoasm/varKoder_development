# varKoder development

This repository holds scripts used in the initial development of varKoder. See the following publications for details:

de Medeiros, B.A.S., Cai, L., Flynn, P.J. et al. A composite universal DNA signature for the tree of life. Nat Ecol Evol (2025). https://doi.org/10.1038/s41559-025-02752-1

Asprino, R.C., Cai, L., Yan, Y. , ..., Davis, C.C., de Medeiros, B.A.S. A curated benchmark dataset for molecular identification based on genome skimming. Sci Data 12, 906 (2025). https://doi.org/10.1038/s41597-025-05230-2

It has also been archived on Figshare:
de Medeiros et al. Archived code for: A composite universal DNA signature for the Tree of Life. Figshare https://doi.org/10.6084/m9.figshare.8304017 (2025).

## varKoder_mapping

This folder holds code used to develop the k-mer mapping used in varKodes

## varkoder_design

This folder holds code used to design varKoder and test the effects of training hyperparameters with a dataset of species of Stigmaphyllon

## varkoder_tests

This folders holds codes and results when testing varKoder with broader datasets and comparing to alternative tools

Folders:

other_datasets: tests with 4 species-level datasets

additional_tests_cgr: tests comparing 4 NN architectures and 3 image representations with the Malpighiales dataset

all_SRA_eukaryote_families: tests with all Eukaryote families on NCBI SRA

images_manuscript: files generated for the manuscript

Malpighiales: tests with the Malpighiales dataset

all_SRA_taxa: tests using all taxa available on NCBI SRA

iDELUCS: tests using iDELUCS

## figures
This folder holds scripts and data to reproduce varKodes and rfCGRs shown in Figure 1 and Figure 3 in the manuscript.

## profiling 
Log files produced by varKoder tests with profiling activated.

Settings used:
For all:
- local installation
- ViT model
- 30 pretraining epochs
- 5 fine-tuning epochs


MacStudio: 8 cores
MacbookAir: 6 cores
Linux: 24 cores, One NVIDIA A5000 GPU 

