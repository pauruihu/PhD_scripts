#!/bin/bash

SPADES=/home/paula/programas/SPAdes-3.9.0-Linux/bin
PATH_cleanedfastq=/datos/Pseudomonas_HGral/data/fastq_cleaned-merged/autoadapt/prinseq

mkdir ./Ensamblados
cd ./Ensamblados

for i in /datos/Pseudomonas_HGral/data/fastq_cleaned-merged/autoadapt/prinseq/*_1.fastq; do
x=`echo $i | sed 's/\/datos\/Pseudomonas_HGral\/data\/fastq_cleaned-merged\/autoadapt\/prinseq\///' | cut -f 1 -d "_" `;
z=`echo $i | sed 's/\/datos\/Pseudomonas_HGral\/data\/fastq_cleaned-merged\/autoadapt\/prinseq\///' | sed 's/_1.fastq//'`;
$SPADES/spades.py -o "$x"_SPADES --careful -1 $PATH_cleanedfastq/"$z"_1.fastq -2 $PATH_cleanedfastq/"$z"_2.fastq -m 8 -k 31,55,77,101 --cov-cutoff auto; 
done