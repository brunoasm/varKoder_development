#!/bin/bash

set +e
source /home/bdemedeiros/software/miniconda3/etc/profile.d/conda.sh
conda activate varKoder

varKoder convert cgr varKodes cgrs -n 20
