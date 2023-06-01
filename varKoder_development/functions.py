import pandas as pd
import numpy as np
from pathlib import Path

from fastai.data.all import DataBlock, ColSplitter, ColReader, get_c
from fastai.vision.all import ImageBlock, CategoryBlock, cnn_learner, create_head, apply_init, default_split
from fastai.vision.learner import _update_first_layer, has_pool_type
from fastai.vision.all import aug_transforms
#from fastai.vision.all import xresnet50, resnet34, densenet121, densenet161, 
from fastai.vision.all import xresnet50
from fastai.metrics import accuracy
from fastai.learner import Learner, load_learner
from fastai.torch_core import set_seed
from fastai.callback.mixup import CutMix, MixUp
from fastai.callback.hook import num_features_model
from fastai.losses import LabelSmoothingCrossEntropyFlat, CrossEntropyLossFlat

from torch.cuda import get_device_name
from torch import nn

from timm import create_model
from math import log
from IPython.display import clear_output


## These functions use timm to create a fastai model
## source: https://walkwithfastai.com/vision.external.timm
def create_timm_body(arch:str, pretrained=True, cut=None, n_in=3):
    "Creates a body from any model in the `timm` library."
    model = create_model(arch, pretrained=pretrained, num_classes=0, global_pool='')
    _update_first_layer(model, n_in, pretrained)
    if cut is None:
        ll = list(enumerate(model.children()))
        cut = next(i for i,o in reversed(ll) if has_pool_type(o))
    if isinstance(cut, int): return nn.Sequential(*list(model.children())[:cut])
    elif callable(cut): return cut(model)
    else: raise NamedError("cut must be either integer or function")
    
def create_timm_model(arch:str, n_out, cut=None, pretrained=True, n_in=3, init=nn.init.kaiming_normal_, custom_head=None,
                     concat_pool=True, **kwargs):
    "Create custom architecture using `arch`, `n_in` and `n_out` from the `timm` library"
    body = create_timm_body(arch, pretrained, None, n_in)
    if custom_head is None:
        nf = num_features_model(nn.Sequential(*body.children()))
        head = create_head(nf, n_out, concat_pool=concat_pool, **kwargs)
    else: head = custom_head
    model = nn.Sequential(body, head)
    if init is not None: apply_init(model[1], init)
    return model

def timm_learner(dls, arch:str, loss_func=None, pretrained=True, cut=None, splitter=None,
                y_range=None, config=None, n_out=None, normalize=True, **kwargs):
    "Build a convnet style learner from `dls` and `arch` using the `timm` library"
    if config is None: config = {}
    if n_out is None: n_out = get_c(dls)
    assert n_out, "`n_out` is not defined, and could not be inferred from data, set `dls.c` or pass `n_out`"
    if y_range is None and 'y_range' in config: y_range = config.pop('y_range')
    model = create_timm_model(arch, n_out, default_split, pretrained, y_range=y_range, **config)
    learn = Learner(dls, model, loss_func=loss_func, splitter=default_split, **kwargs)
    if pretrained: learn.freeze()
    return learn


#Function: select training and validation set given kmer size and amount of data (as a list).
#minbp_filter will only consider samples that have yielded at least that amount of data
def get_training_set(kmer_size, bp_training, n_valid = 3, minbp_filter = 200000000):
    file_path = [x.absolute() for x in (Path('images_' + str(kmer_size))).ls() if x.suffix == '.png']
    taxon = [x.name.split('+')[0] for x in file_path]
    sample = [x.name.split('+')[-1].split('_')[0] for x in file_path]
    n_bp = [int(x.name.split('_')[-1].split('.')[0].replace('K','000')) for x in file_path]

    df = pd.DataFrame({'taxon': taxon,
                  'sample': sample,
                  'n_bp': n_bp,
                  'path': file_path
                 })
    
    if minbp_filter is not None:
        included_samples = df.loc[df['n_bp'] == 200000000]['sample'].drop_duplicates()
    else:
        included_samples = df['sample'].drop_duplicates()
        
    df = df.loc[df['sample'].isin(included_samples)]

    valid = (df[['taxon','sample']].
             drop_duplicates().
             groupby('taxon').
             apply(lambda x: x.sample(n_valid, replace=False)).
             reset_index(drop=True).
             assign(is_valid = True).
             merge(df, on = ['taxon','sample'])
        )

    train = (df.loc[~df['sample'].isin(valid['sample'])].
             assign(is_valid = False)
            )
    train = train.loc[train['n_bp'].isin(bp_training)]

    train_valid = pd.concat([valid, train]).reset_index(drop = True)
    return train_valid     

#Function: create a learner and fit model, setting batch size according to number of training images
def train_cnn(df, 
              architecture = xresnet50, 
              epochs = 30, 
              normalize = True, 
              pretrained = True, 
              callbacks = CutMix, 
              transforms = None,
              loss_fn = LabelSmoothingCrossEntropyFlat()):
    #find a batch size that is a power of 2 and splits the dataset in about 10 batches
    batch_size = min(2**round(log(df[~df['is_valid']].shape[0]/10,2)), 64) 
    
    #start data block
    dbl = DataBlock(blocks=(ImageBlock, CategoryBlock),
                       splitter = ColSplitter(),
                       get_x = ColReader('path'),
                       get_y = ColReader('taxon'),
                       item_tfms = None,
                       batch_tfms = transforms
                      )
    
    #create data loaders with calculated batch size
    dls = dbl.dataloaders(df, bs = batch_size)
    
   
    #create learner and train for the number of epochs requested
    learn = timm_learner(dls, 
                    architecture, 
                    metrics = accuracy, 
                    normalize = normalize,
                    pretrained = pretrained,
                    cbs = callbacks,
                    loss_func = loss_fn
                   ).to_fp16()
    
    #to speed up training, we will skip validation in each cycle and only do it at the end
    valid = learn.dls.valid
    learn.dls.valid = []
    
    with learn.no_logging():
        with learn.no_bar():
            learn.fine_tune(epochs = epochs, freeze_epochs = 0, base_lr = 1e-3)
        
    #now we can put the validation dataloader back    
    learn.dls.valid = valid
    
    return(learn)

#Function: get overall accuracy given a model, a table and amount of basepairs
def get_accuracy(learner, df, bp_test):
    test = df[(df['is_valid'] == True) & df['n_bp'].isin(bp_test)]
    tdl = learner.dls.test_dl(test, with_labels = True)
    return learner.validate(dl = tdl)

#Function: get prediction for each image in validation set
def get_predictions(learner, df, bp_test):
    test = df[(df['is_valid'] == True) & df['n_bp'].isin(bp_test)]
    tdl = learner.dls.test_dl(test, with_labels = True)
    preds = list(learner.dls.vocab[np.argmax(learner.get_preds(dl = tdl)[0],1)])

    
    return pd.DataFrame({'actual':test['taxon'], 
                         'sample':test['sample'],
                         'prediction':preds, 
                         'bp_valid':test['n_bp']})

