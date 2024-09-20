#!/bin/bash

conda create --force -n idelucs python=3.11 pip setuptools conda-forge::parallel conda-forge::exiftool
conda activate idelucs

git clone https://github.com/millanp95/iDeLUCS.git iDeLUCS
cd iDeLUCS
python setup.py build_ext --inplace
pip install -e .
