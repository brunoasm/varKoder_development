#!/usr/bin/env python
# coding: utf-8

# # Test effect of sample qualiy on accuracy

# We previously established the best kmer size and training parameters. Here we will test the effects of sample quality. He we will read the fastp file to retrieve insert size and an estimator of DNA damage. This estimator will be the covariance between frequency of T and base position in read 1 between bases 10 and 20. DNA damage causes C to T transitions, and these are increased towards the end of the read. We start counting at base 10 since composition is unstable at the 5' end due to other reasons and we do it until base 20 to guarantee this is independent of total read length.

# In[1]:


from functions import *
import warnings, os, json
warnings.filterwarnings('ignore')

get_device_name(0)


# Let's read json files and assemble sample quality statistics.

# In[2]:


df = pd.read_csv('sample_info.csv')
df


# In[3]:


def get_stats(libid):
    json_file = [x for x in (Path('intermediate_files')/'clean_reads').glob('*+' + libid + '_*.json')][0]
    js = json.load(open(json_file,'r'))
    ins = js['insert_size']['histogram']
    ave_insert = sum(np.array(ins) * np.array(range(len(ins))))/sum(ins)
    content = np.array([x for k,x in js['merged_and_filtered']['content_curves'].items() if k in ['A','T','C','G']])
    content_sd = np.std(content[:,20:50], axis = 1).mean()
    return({'insert_size':ave_insert, 'content_sd':content_sd})


# In[4]:


df = pd.concat([df, pd.DataFrame(df['library_id'].apply(get_stats).tolist())],1).sort_values('content_sd')
df.to_csv('sample_info_stats.csv')
df


# In[5]:


df.plot.scatter(x='insert_size',y='content_sd', c = df['species'].astype('category').cat.codes+1, cmap='turbo')


# In[6]:


df['content_sd'].plot.hist()


# In[7]:


pd.concat([df['species'].astype('category'),df['species'].astype('category').cat.codes+1],1).drop_duplicates()


# It seems S. cilliatum  and S. bannisteroides have some of the lowest-quality libraries. Now we will test what happens when we include or exclude poor libraries from training. Let's mark which ones are these.

# In[8]:


lowest_insert_size = df.sort_values('insert_size').groupby('species').head(4)['library_id']
highest_c_sd = df.sort_values('content_sd').groupby('species').tail(4)['library_id']

df


# For each quality measure, let's now do the following: train the model with 5 samples per species, and check whether this model can correctly guess each of the other samples. These 5 species will consist from 0-3 lowest quality samples and the remaining of highest quality samples. We will repeat this 30 times for each combination o quality metric and number of low quality samples.
# 

# In[9]:


kmer_size = 7
all_bp_tr = [x*1e6 for x in [1,2,5,10,20,50,100,200]]

file_path = [x.absolute() for x in (Path('images_' + str(kmer_size))).ls() if x.suffix == '.png']
taxon = [x.name.split('+')[0] for x in file_path]
sample = [x.name.split('+')[-1].split('_')[0] for x in file_path]
n_bp = [int(x.name.split('_')[-1].split('.')[0].replace('K','000')) for x in file_path]

images = pd.DataFrame({'taxon': taxon,
              'sample': sample,
              'n_bp': n_bp,
              'path': file_path
             })

images = images.loc[images['n_bp'].isin(all_bp_tr)]

images['low_size'] = images['sample'].isin(lowest_insert_size)
images['high_c_sd'] = images['sample'].isin(highest_c_sd)
images


# Now that we defined functions, let's train the CNN while varying some parameters. Let's start by making a list containing the training conditions we want to test.

# In[10]:


with open('sample_quality.txt','w') as outfile:
    for qual_metric in ['low_size', 'high_c_sd']:
        for n_lowqual in range(4):
            for replicate in range(30):
                clear_output()
                print('Metric',qual_metric)
                print('N low qual', n_lowqual)
                print('Replicate', replicate)
                include_lowqual = (images.
                                   loc[images[qual_metric],['taxon','sample']].
                                   drop_duplicates().
                                   groupby('taxon').
                                   sample(n_lowqual).
                                   loc[:,'sample']
                                  )
                include_highqual = (images.
                                   loc[~images[qual_metric],['taxon','sample']].
                                   drop_duplicates().
                                   groupby('taxon').
                                   sample(5 - n_lowqual).
                                   loc[:,'sample']
                                  )
                all_includes = pd.concat([include_highqual, include_lowqual])

                valid = images.loc[~images['sample'].isin(all_includes)].reset_index(drop=True).assign(is_valid = True)
                train = images.loc[images['sample'].isin(all_includes)].reset_index(drop=True).assign(is_valid = False)

                df = pd.concat([valid, train]).reset_index(drop = True)

                learn = train_cnn(df, 
                                  architecture = 'ig_resnext101_32x8d',
                                  pretrained = False,
                                  callbacks = CutMix,
                                  transforms = aug_transforms(do_flip = False,
                                                  max_rotate = 0,
                                                  max_zoom = 1,
                                                  max_lighting = 0.5,
                                                  max_warp = 0,
                                                  p_affine = 0,
                                                  p_lighting = 0.75
                                                 ),
                                  loss_fn = CrossEntropyLossFlat()
                                 )
                preds = get_predictions(learn, df, all_bp_tr)
                preds['lowqual'] = preds['sample'].isin(images.loc[images[qual_metric],'sample'].drop_duplicates())

                for i,x in preds.iterrows():

                    entry = dict(kmer_size=kmer_size,
                                 replicate = replicate,
                                 bp_training = '|'.join([str(x) for x in sorted(all_bp_tr)]),
                                 bp_valid = x['bp_valid'],
                                 samples_training = '|'.join(df.loc[~df['is_valid']]['sample'].drop_duplicates().sort_values().tolist()),
                                 n_samp_training = df.loc[~df['is_valid']]['sample'].drop_duplicates().shape[0],
                                 n_lowqual_training = n_lowqual,
                                 qual_metric = qual_metric,
                                 sample_valid = x['sample'],
                                 valid_actual = x['actual'],
                                 valid_prediction = x['prediction'],
                                 valid_lowqual = x['lowqual'])
                    print(entry, file = outfile)

print('DONE')
            


# Now that we finished training and testing all models, let's save results as a table that can be easily read in R:

# In[11]:


with open('sample_quality.txt','r') as infile:
    df = pd.DataFrame([eval(x) for x in infile])
    df.to_csv('sample_quality.csv')

Path('sample_quality.txt').unlink()

print('DONE')


# In[ ]:




