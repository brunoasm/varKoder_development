import fnmatch,os

#assign species ID to actual species
sp_asgn={}
for i in range(1,101):
	sp_asgn['S-'+`i`]=i/10

sp_asgn['S-10']=0
sp_asgn['S-20']=1
sp_asgn['S-30']=2
sp_asgn['S-40']=3
sp_asgn['S-50']=4
sp_asgn['S-60']=5
sp_asgn['S-70']=6
sp_asgn['S-80']=7
sp_asgn['S-90']=8
sp_asgn['S-100']=9

	
def blast_best_hit(cov):
	filename=[]
	for fn in os.listdir('.'):
   		if fnmatch.fnmatch(fn,'*'+cov+'.aba.blast'):filename.append(fn)
   	for gene in filename:
   		x=open(gene).readlines()
   		#get best non-self hit
   		best_hit={}
   		cur_sp=''
   		for l in x:
   			if l.split()[0]!=cur_sp:
   				if l.split()[0]!=l.split()[1]:
   					cur_sp=l.split()[0]
   					best_hit[cur_sp]=l.split()[1]
   		#output to file
   		out1=open(gene+'.best_hit_sp.tsv','a')
   		out2=open(gene+'.sp_assignment.tsv','a')
   		for i in range(1,101):
   			try:
   				out1.write('S-'+`i`+'\t'+best_hit['S-'+`i`]+'\n')
   				if sp_asgn['S-'+`i`]==sp_asgn[best_hit['S-'+`i`]]:
   					out2.write('S-'+`i`+'\tT\n')
   				else:
   					out2.write('S-'+`i`+'\tF\n')
   			except KeyError:
   				out1.write('S-'+`i`+'\tNO BLAST HIT\n')
   				out2.write('S-'+`i`+'\tNO BLAST HIT\n')
   		out1.close()
   		out2.close()


blast_best_hit('complete')
blast_best_hit('200m.1')
blast_best_hit('100m.1')
blast_best_hit('50m.1')
blast_best_hit('20m.1')
blast_best_hit('10m.1')