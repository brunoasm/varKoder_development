#!/bin/bash

conda activate idelucs

find fastas/ -name '*.fasta' | parallel --bar -j 20 -I {} python 3_make_cgr.py {}
 
