makeblastdb -in $1.$2.1.fas -dbtype nucl -out $1.$2
blastn -task dc-megablast -db $1.$2 -query $1.$2.1.fas -outfmt 6 -evalue 1e-40 -out $1.$2.1.aba.blast
mafft-linsi --adjustdirection $1.$2.1.fas | sed 's/_R_//g'> $1.$2.1.aln.fas
iqtree2 -redo -s $1.$2.1.aln.fas -m GTR+G -B 1000 -bnni --prefix $1.$2.1
rm $1.$2.n*
