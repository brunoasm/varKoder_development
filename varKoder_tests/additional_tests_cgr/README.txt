# Comparing NN architectures and image representations

This folder contains code to compare the performance of varKodes with two alternative representations: fCGR and a new representation with fCGR mapping but varKode data transformation.

In the publication, we name these varKode, fCGR and vk-fCGR. Here, these images are contained in folders varKodes, cgr_idelucs and cgr_varKoder, respectively.

We additionally compare 4 neural network architectures: ViT, resnext101 and two simpler neural networks previously employed in other papers: a shallow flattened convolutional neural network (fiannaca2018) and a multilayer perceptron (arias2022).

The code to produce fCGRs using idelucs functions can be found in folder make_cgrs. These images were then transferred to datasets/cgr_idelucs

vk-fCGRs were created by converting varKodes using:

```
varKoder convert -n 30 --overwrite cgr ./varKodes/ ./cgr_varKoder/
```

