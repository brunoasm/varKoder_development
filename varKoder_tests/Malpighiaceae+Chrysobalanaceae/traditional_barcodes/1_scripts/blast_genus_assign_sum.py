x=open('../10M.list').readlines()
x=[i.split()[-1] for i in x]
x=[i.split('.')[0] for i in x]
ya=open('10M/matK.blast.top').readlines()
yb=open('10M/rbcL.blast.top').readlines()
yc=open('10M/ndhF.blast.top').readlines()
yd=open('10M/trnL-F.blast.top').readlines()
ye=open('10M/ITS.blast.top').readlines()

a={}
for l in ya:
	a[l.split()[0]]=l.split()[1]
	


b={}
for l in yb:
	b[l.split()[0]]=l.split()[1]
	


c={}
for l in yc:
	c[l.split()[0]]=l.split()[1]



d={}
for l in yd:
	d[l.split()[0]]=l.split()[1]



e={}
for l in ye:
	e[l.split()[0]]=l.split()[1]

out=open('10M_blast_sum.tsv','a')
out.write('sp\tmatK\trbcL\tndhF\ttrnL-F\tITS\n')

for i in x:
	ltext=i+'\t'
	try:ltext=ltext+a[i]+'\t'
	except KeyError:ltext=ltext+'FAIL\t'
	try:ltext=ltext+b[i]+'\t'
	except KeyError:ltext=ltext+'FAIL\t'
	try:ltext=ltext+c[i]+'\t'
	except KeyError:ltext=ltext+'FAIL\t'
	try:ltext=ltext+d[i]+'\t'
	except KeyError:ltext=ltext+'FAIL\t'
	try:ltext=ltext+e[i]+'\t\n'
	except KeyError:ltext=ltext+'FAIL\t\n'
	z=out.write(ltext)


##############################
#Check genus

x=open('/Users/limingcai/Documents/GitHub/Malpighiaceae_herbarium_phylogenomics/2_phylogeny/ID_Sp.csv').readlines()
a={}
for l in x[1:]:
	a[l.split(',')[0]]=l.split(',')[2]

x=open('10M_blast_sum.tsv').readlines()
out=open('10M_blast_sum_TF.tsv','a')
out.write(x[0])
for l in x[1:]:
	i=l.split()[0]
	ltext=i+'\t'
	try:
		#not chrysobalanaceae
		Tgenus=a[i]
		try:
			if a[l.split()[1]]==Tgenus:
				ltext=ltext+'T\t'
			else:
				ltext=ltext+'F\t'
		except KeyError:ltext=ltext+'FAIL\t'
		try:
			if a[l.split()[2]]==Tgenus:
				ltext=ltext+'T\t'
			else:
				ltext=ltext+'F\t'
		except KeyError:ltext=ltext+'FAIL\t'
		try:
			if a[l.split()[3]]==Tgenus:
				ltext=ltext+'T\t'
			else:
				ltext=ltext+'F\t'
		except KeyError:ltext=ltext+'FAIL\t'
		try:
			if a[l.split()[4]]==Tgenus:
				ltext=ltext+'T\t'
			else:
				ltext=ltext+'F\t'
		except KeyError:ltext=ltext+'FAIL\t'
		try:
			if a[l.split()[5]]==Tgenus:
				ltext=ltext+'T\t\n'
			else:
				ltext=ltext+'F\t\n'
		except KeyError:ltext=ltext+'FAIL\t\n'
		z=out.write(ltext)
	except KeyError:
		#chrysobalanaceae
		z=out.write(l)