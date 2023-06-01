# Testing varKoder for species-level barcoding

In this folder, we used python scripts and jupyter notebooks to develop varKoder. We start by figuring out the best hyperparameters to train a NN, and then test whether sample number and quality impacts results.

We start with the table `sample_info.csv`, containing basic information about each sample. 

Then we run the following scripts, in this order. The R script `varKode_evaluation.Rmd` was written to visualize results from each jupyter notebook and inform parameters for the next one.

1. `make_dsets.sh`: this calls `varKoder` to preprocess fastq files and generate image files from different kmer sizes and amounts of data per sample that we will use for training. These files are stored in folders named `images_*`. Intermediate files generated in the process are stored in the folder `intermediate_files`. Sample metrics and run times are saved to `stats.csv`

2. `kmerSize_VS_bp.ipynb`: we start by asking what is the optimal kmer size and amount of data per sample (in base pairs). We use a resnet50 archictecture, pretrained on imagenet and with Label Smoothing and CutMix for training, since this seemed to be a sensible approach based on early trials. We vary the kmer size in input images and the number of base pairs in input images. For each combination of these two parameters, we do 10 replicates, in each replicate randomly leaving 3 samples per species as validation. Results were saved to `kmerSize_VS_bp.csv`.

3. `training_params.ipynb`: with the previous script we found out that a kmer size of 7 seems optimal and that it is best to include in the training set a combination of images for each sample, produced from several amounts of data. Now we test if the hyperparameters used for training were optimal. For that, we test:
    * different model architectures
    * whether models are pretrained
    * whether CutMix or MixUp are applied
    * whether Label Smoothing is applied
    We tested all combinations of all these parameters, with 30 replicates per combination. For each replicate, we randomly chose 3 samples per species as validation and left the remaining 7 as training data. Models were unfrozen and trained for 30 epochs, which should be sufficient to reach maximum accuracy and potentially even overfit. Results were saved to `training_params.csv`.
    
4. `sample_quality.ipynb`: after establishing the best training strategy, we ask whether the quality of samples used in validation and training sets can impact inferences. We use two metrics to assess quality, both obtained with [fastp](https://github.com/OpenGene/fastp): average insert size and standard deviation of average base frequencies across sequences. Good samples are expected to have large insert sizes and homogeneous GC content along reads, leading to low standard deviation. In this case, we trained models using 5 samples per species, validating with the other 5. For each quality metric, we set aside the worst 4 samples per species according to that metric. We tested including from 0 to 4 of these samples in the training set, randomly choosing in each replicate and doing 50 replicates for each quality metric and number of bad samples included. Results were saved to `sample_quality.csv`. It also generates `sample_info_stats.csv`, which contains the same information as `sample_info.csv`, but also quality metrics.

5. `n_samples.ipynb`: because it is generally thought that AI requires very large training sets, we need to establish how many samples we need to adequately train a model. Here we test including from 1 to 7 randomly chosen samples per species in the training set and 3 randomly chosen samples per species in the validation set. We did 50 replicates per each number of samples. We changed training batch sizes according to the number of input images, so that each epoch would see at least about 10 batches. In prior attempts we found that this can have a great impact when a low number of images is used for training. Results were saved in `n_training.csv`

