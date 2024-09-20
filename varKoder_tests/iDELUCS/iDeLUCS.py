import sys


import numpy as np
import matplotlib.pyplot as plt 
import umap


from idelucs.utils import SummaryFasta, kmersFasta, cluster_acc
from idelucs.cluster import iDeLUCS_cluster

fasta_file = "conc.10m.aln.fas"
GT_file = "conc_GT.tsv"
k = 6

names, lengths, ground_truth, cluster_dis =  SummaryFasta(fasta_file, GT_file=GT_file)

print("The cluster distribution is:")
print (cluster_dis)


stats = {"n_seq": len(lengths),
        "min_len": np.min(lengths),
        "max_len": np.max(lengths),
        "avg_len": np.mean(lengths)}

print( f'No. Sequences: \t {stats["n_seq"]:,}')
print(f'Min. Length: \t {stats["min_len"]:,}')
print(f'Max. Length: \t {stats["max_len"]:,}')
print(f'Avg. Length: \t {round(stats["avg_len"],2):,}')


_, kmers = kmersFasta(fasta_file, k=k, transform=None, reduce=False)
unique = sorted(list(set(ground_truth)))
GT = list(map(lambda x: unique.index(x), ground_truth))

print(kmers.shape)

n_cluster = 10
params = {
    "iDeLUCS": {'sequence_file':fasta_file,'n_clusters':n_cluster, 'n_epochs':50,
                'n_mimics':50, 'batch_sz':512, 'k':k, 'weight':0.75, 'n_voters':5},
    }

# Definition of the clustering algorithms for now only iDeLUCS but you can add other to compare
clustering_algorithms = (
    ("iDeLUCS", iDeLUCS_cluster),
)

for name, algorithm in clustering_algorithms:
	print(f'....{name}...')                
	model = algorithm(**params[name])
	y_pred, latent = model.fit_predict(fasta_file )

ind, d = cluster_acc(np.array(GT).reshape(-1,1), y_pred)
print(f"\n The accuracy of the model is: {d}")
#d_200m 0.59
#d_100m 0.6
#d_50m 0.29
#d_20m 0.27
#d_10m 0.29