#!/usr/bin/env python
# coding: utf-8

# # Test effect of training parameters on accuracy

# We previously established that a kmer size of 7 seems to be the best balance between accuracy and amount of data.
# 
# Even though we assumed that CutMix, label smoothing and using a pretrained network help, we still have to show this is the case, which is what we will do here. We will also test a few different network architectures.
# 
# We will use 4 images per sample for training, including 1, 10, 100 and 200 Mbp

# In[8]:


from functions import *
from fastai.losses import LabelSmoothingCrossEntropyFlat, CrossEntropyLossFlat, LabelSmoothingCrossEntropy
from torch.nn import CrossEntropyLoss
from fastai.callback.mixup import CutMix, MixUp
from numpy import nan
import warnings
import os
warnings.filterwarnings('ignore')

get_device_name(0)


# Now that we defined functions, let's train the CNN while varying some parameters. Let's start by making a list containing the training conditions we want to test.

# In[9]:


set_seed(123151)
kmer_len = 7

pars_list = []
for aug in (True, False): 
    for pre_tr in (True, False):
        for arch in ['wide_resnet50_2',
                     'ig_resnext101_32x8d',
                     'efficientnet_b4', 
                     'resnet50', 
                     'resnet50d',
                     'resnet18d',
                     'resnet101d'
                    ]:
            temp = [{'callback':CutMix, 'loss_fn':LabelSmoothingCrossEntropyFlat()},
                    {'callback':MixUp, 'loss_fn':LabelSmoothingCrossEntropyFlat()},
                    {'callback':None, 'loss_fn':LabelSmoothingCrossEntropy()},
                    {'callback':CutMix, 'loss_fn':CrossEntropyLossFlat()},
                    {'callback':MixUp, 'loss_fn':CrossEntropyLossFlat()},
                    {'callback':None, 'loss_fn':CrossEntropyLoss()},
                    ]
            for t in temp:
                t.update({'pretrained':pre_tr, 'arch':arch, 'transforms':aug})
            pars_list.extend(temp)
pars_list[:5]


# In[10]:


with open('training_params.txt','w') as outfile:
    for replicate in range(20):        
        for pars in pars_list:
            
            if pars['transforms']:
                trans = aug_transforms(do_flip = False,
                                                  max_rotate = 0,
                                                  max_zoom = 1,
                                                  max_lighting = 0.5,
                                                  max_warp = 0,
                                                  p_affine = 0,
                                                  p_lighting = 0.75
                                                 )
            else:
                trans = None
            
            clear_output()
            print('Training using all bp amounts for kmer size', kmer_len)
            print(pars)
            print('Replicate', replicate)
            all_bp_tr = [x*1e6 for x in [0.5,1,2,5,10,20,50,100,200]]

            #training with all bp amounts
            df = get_training_set(kmer_len, all_bp_tr)
            learn = train_cnn(df, 
                              architecture = pars['arch'],
                              pretrained = pars['pretrained'],
                              callbacks = pars['callback'],
                              loss_fn = pars['loss_fn'],
                              transforms = trans
                             )

            #recording validation accuracy for different bp amounts
            print('Recording accuracy')
            for bp_valid in all_bp_tr:
                with learn.no_bar():
                    acc = get_accuracy(learn, df, [bp_valid])
                print(bp_valid, acc[1])
                
                entry = dict(kmer_size=kmer_len,
                             replicate = replicate,
                             bp_training = '|'.join([str(x) for x in sorted(all_bp_tr)]),
                             bp_valid = bp_valid,
                             samples_training = '|'.join(df.loc[~df['is_valid']]['sample'].drop_duplicates().sort_values().tolist()),
                             n_samp_training = df.loc[~df['is_valid']]['sample'].drop_duplicates().shape[0],
                             samples_valid = '|'.join(df.loc[df['is_valid']]['sample'].drop_duplicates().sort_values().tolist()),
                             n_samp_valid = df.loc[df['is_valid']]['sample'].drop_duplicates().shape[0],
                             callback = str(pars['callback']),
                             label_smoothing = 'LabelSmoothing' in str(pars['loss_fn']),
                             pretrained = pars['pretrained'],
                             arch = pars['arch'],
                             trans = trans,
                             valid_loss = acc[0],
                             valid_acc = acc[1])
                print(entry, file = outfile, flush=True)
                

print('DONE')


# Now that we finished training and testing all models, let's save results as a table that can be easily read in R:

# In[ ]:


with open('training_params.txt','r') as infile:
    df = pd.DataFrame([eval(x) for x in infile])
    df.to_csv('training_params.csv')

Path('training_params.txt').unlink()


# Because all of these computations take a while, we exported this notebook as a python script and ran it using sbatch instead of interactively.

# In[ ]:




