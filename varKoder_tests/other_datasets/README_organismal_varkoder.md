#  Testing other Organismal Datasets

### Dependencies 
These two programs were installed on computer before running analyses: <br>

 - [Sra-Toolkit](https://github.com/ncbi/sra-tools/wiki/02.-Installing-SRA-Toolkit) <br>
 - [VarKoder](https://github.com/brunoasm/varKoder)

### Obtaining Data 

1. Each taxa tested used a different genome skim dataset from a specific study -- <br> [**plant**](https://nph.onlinelibrary.wiley.com/doi/full/10.1111/nph.15072): *Corallorhiza* species/varieties, <br> [**animal**](https://academic.oup.com/sysbio/article/69/6/1137/5817835): *Bembidion* species, <br> [**fungal**](https://www.sciencedirect.com/science/article/abs/pii/S1055790322001567): *Xanthoparmelia* species, <br> [**bacterial**](https://www.nature.com/articles/s41467-021-26248-1): *Mycobacterium tuberculosis* isolates. 
 

2. For each sample within the dataset, the accession number from NCBI was determined and the raw reads were downloaded using the sra-toolkit. These files were then converted from sra to fastq format.
```sh
prefetch SRR2101363.sra
fasterq-dump --split-files SRR2101363.sra
```
### VarKoder commands
3. VarKoder program activated on conda
```sh
conda activate varKoder
``` 
#### Varkode images
4. The first VarKode command processes the raw sequencing reads and creates *VarKodes*, or images which are representative of K-mer frequencies. Below is an example of the command given for the *Bembidion* dataset:


#### Varkode model training
5. For each organismal dataset at least three monophyletic samples per species were used to train model with five species per dataset. We assessed monophyly based on the phylogenies within the studies the samples were found. For example, In our animal genome skim dataset of *Bembidion* beetles, we based our assessment on this phylogeny: <br>

<img src="Bembidion_Sproul_2020.jpeg" alt="drawing" width="400"/> <br>
(*Bembidion phylogeny from Sproul et al. 2020*)

These were the 5 samples from 5 species each we ended up using:

| Species |SRA/SAMN Number | Reads |
| :---------- | :---------- | :---------- |
| Bembidion ampliatum | SAMN10860546 | 1271228 |
| Bembidion ampliatum | SAMN10860547 | 30203860 |
| Bembidion ampliatum | SAMN10860544 | 14438858 |
| Bembidion ampliatum | SAMN10860545 | 32232226 |
| Bembidion ampliatum | SAMN10860550 | 14959056 |
| Bembidion breve | SAMN10860556 | 24662424 |
| Bembidion breve | SAMN10860557 | 16272652 |
| Bembidion breve | SAMN10860554 | 27815502 |
| Bembidion breve | SAMN10860555 | 13275064 |
| Bembidion breve | SAMN10860558 | 28440590 |
| Bembidion lividulum | SAMN10860567 | 15961124 |
| Bembidion lividulum | SAMN10860571 | 25155782 |
| Bembidion lividulum | SAMN10860570 | 31057860 |
| Bembidion lividulum | SAMN10860569 | 12290094 |
| Bembidion lividulum | SAMN10860568 | 12702920 |
| Bembidion saturatum | SAMN10860582 | 35606542 |
| Bembidion saturatum | SAMN10860583 | 13464230 |
| Bembidion saturatum | SAMN10860578 | 30554874 |
| Bembidion saturatum | SAMN10860579 | 22962946 |
| Bembidion saturatum | SAMN10860580 | 12553516 |
| Bembidion testatum | SAMN10860589 | 13220490 |
| Bembidion testatum | SAMN10860588 | 23270922 |
| Bembidion testatum | SAMN10860585 | 17093392 |
| Bembidion testatum | SAMN10860584 | 12968062 |
| Bembidion testatum | SAMN10860587 | 11760714 |



For the *Corallorhiza* dataset, we used 5 species/species varities with 5 samples each. For the *Xanthoparmelia* dataset, we were not able to obtain 5 monophyletic sample per species due to  . For the *Mycobacterium tuberculosis* dataset, we used 5 distinct lineages (L1, L2, L3, 4.1.i1.2.1, and L4.3.i2) each with 5 clinical isolate samples.


The output for the Bembidion beetle model training looked like with the final trained model have an precision, recall, and area under ROC curve scores of **1.0** (epoch 29): 
```sh
epoch     train_loss valid_loss roc_auc  precision recall    time    
0          18.040171 17.303974  0.954865         0 0.000000  00:17                                                           
1          10.684855  10.43271         1   0.96875 1.000000  00:14                                                           
2         7.609478  8.544642           1  0.805195 1.000000  00:57                                                          
3         5.912435  5.773278           1  0.873239 1.000000  00:19                                                          
4         4.838060  8.901415           1  0.596154 1.000000  00:34                                                          
5         4.196673  1.876863           1  0.953846 1.000000  00:14                                                          
6         3.541138  9.586188    0.999935  0.558559 1.000000  00:14                                                          
7         2.991792  7.883916    0.994277  0.810811 0.967742  00:14                                                          
8         2.528411  1.708431           1  0.953846 1.000000  01:23                                                          
9         2.209080   68.397507  0.905567  0.404959 0.790323  00:37                                                           
10        1.915586   34.553219   0.96345  0.509615 0.854839  00:39                                                           
11        1.738567   33.478893  0.946475  0.558559 1.000000  00:16                                                           
12        1.660880   45.540485  0.942638  0.454545 0.806452  00:19                                                           
13        1.461689  0.951072           1  0.911765 1.000000  00:31                                                           
14        1.563728  7.571802           1  0.652632 1.000000  00:14                                                           
15        1.456829   56.301582  0.934703  0.362963 0.790323  00:43                                                           
16        1.310560   27.533026  0.970734  0.505051 0.806452  00:21                                                           
17        1.215083   11.101449  0.981009  0.649351 0.806452  00:49                                                           
18        1.056050  0.900914           1   0.96875 1.000000  01:10                                                           
19        0.931193  0.591885           1  0.984127 1.000000  00:30                                                           
20        0.896020  0.537028           1  0.984127 1.000000  00:14                                                           
21        0.783771  1.145076           1  0.873239 1.000000  00:31                                                           
22        0.729748  0.035133           1         1 1.000000  00:13                                                           
23        0.632886  0.001550           1         1 1.000000  00:13                                                           
24        0.552391  0.000901           1         1 1.000000  00:14                                                           
25        0.489971  0.000807           1         1 1.000000  00:15                                                           
26        0.455342  0.001440           1         1 1.000000  00:14                                                           
27        0.431348  0.002199           1         1 1.000000  00:15                                                           
28        0.378815  0.002689           1         1 1.000000  00:15                                                           
29        0.346677  0.002511           1         1 1.000000  00:14                                                           
                                                           
```

#### VarKode querying 

6. To test if trained models accurately predicted species identity, we queried them using extra genome skim samples from the *same* species included in the trained model as well as genome skim test sample species within the same genus which were *not* trained on the model. We set the threshold to make a prediction to 0.7. This is the minimum confidence necessary (one a scale 0-1) for varKoder to predict a taxon or other label for a given sample. Therefore, the samples from the test species which were not trained on the model should not reach the threshold of **0.7**, and subsequently the query should not be able to make an accurate species prediction for this sample using the trained model. The results below are from the *Bembidion* species queried. Remarkably, we found that our model predicted every sample from species within the model correctly 100% of the time and was unable to predict every sample queried from species not in our model 100% of the time (the predicted label column is blank for these samples). 

| sample_id  | query_bps | prediction_thres | predicted | actual| basefreq_sd | ampliatum | breve | lividulum | saturatum | testatum |
|------------|-----------|------------------|-----------|-----------------|-------------|-----------|-------|-----------|-----------|----------|
| SRR8530107 | 01430654K | 0.7              | testatum  | testatum        | 0.002       | 0.002     | 0.023 | 0.002     | 0.006     | 1.000    |
| SRR8530128 | 01568541K | 0.7              | lividulum | lividulum       | 0.002       | 0.006     | 0.018 | 1.000     | 0.004     | 0.021    |
| SRR8530129 | 02789525K | 0.7              | lividulum | lividulum       | 0.002       | 0.006     | 0.017 | 1.000     | 0.003     | 0.020    |
| SRR8530130 | 02639599K | 0.7              | breve     | breve           | 0.002       | 0.008     | 1.000 | 0.046     | 0.004     | 0.016    |
| SRR8530131 | 01333776K | 0.7              | breve     | breve           | 0.002       | 0.011     | 1.000 | 0.057     | 0.004     | 0.015    |
| SRR8530137 | 01287545K | 0.7              | ampliatum | ampliatum       | 0.002       | 1.000     | 0.036 | 0.010     | 0.005     | 0.003    |
| SRR8530138 | 01438948K | 0.7              | ampliatum | ampliatum       | 0.002       | 1.000     | 0.032 | 0.010     | 0.010     | 0.004    |
| SRR8530139 | 03404235K | 0.7              | ampliatum | ampliatum       | 0.002       | 1.000     | 0.022 | 0.008     | 0.005     | 0.003    |
| SRR8530145 | 00978918K | 0.7              | saturatum | saturatum       | 0.002       | 0.036     | 0.018 | 0.022     | 1.000     | 0.020    |
| SRR8530146 | 39066977K | 0.7              | lividulum | lividulum       | 0.002       | 0.006     | 0.020 | 1.000     | 0.007     | 0.043    |
| SRR8530108 | 01504804K | 0.7              |           | aeruginosum     | 0.003       | 0.315     | 0.147 | 0.022     | 0.271     | 0.369    |
| SRR8530067 | 01171733K | 0.7              |           | geopearlis      | 0.003       | 0.167     | 0.242 | 0.038     | 0.533     | 0.088    |
| SRR8530069 | 01616413K | 0.7              |           | geopearlis      | 0.003       | 0.451     | 0.246 | 0.029     | 0.315     | 0.041    |
| SRR8530092 | 01131271K | 0.7              |           | neocoerulescens | 0.003       | 0.040     | 0.072 | 0.165     | 0.396     | 0.279    |
| SRR8530066 | 01477745K | 0.7              |           | geopearlis      | 0.003       | 0.242     | 0.319 | 0.030     | 0.376     | 0.049    |
| SRR8530060 | 01751755K | 0.7              |           | geopearlis      | 0.003       | 0.062     | 0.308 | 0.033     | 0.447     | 0.161    |
| SRR8530147 | 02929693K | 0.7              |           | oromaia         | 0.002       | 0.135     | 0.078 | 0.021     | 0.196     | 0.623    |
| SRR8530112 | 01275897K | 0.7              |           | curtulatum      | 0.002       | 0.018     | 0.041 | 0.619     | 0.203     | 0.371    |
