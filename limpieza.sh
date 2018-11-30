##Limpieza de muestras
En este caso fueron 2 runs por lo que era necesario primero juntar las reads de ambos para cada una de las muestras:

#!/bin/bash
PATH_SAMPLE1=/datos/Pseudomonas_HGral/raw_data/141205/fastq
PATH_SAMPLE2=/datos/Pseudomonas_HGral/raw_data/141205/fastq
PATH_SAMPLE_OUTPUT=/datos/Pseudomonas_HGral/raw_data/fastq-merged

mkdir $PATH_SAMPLE_OUTPUT;
cd $PATH_SAMPLE1;
for file in ./*.fastq.gz; do
  base=`echo "$file" | sed 's/.fastq.gz//g'`;
	#echo "$base"
	cat $PATH_SAMPLE1/"$base".fastq.gz $PATH_SAMPLE2/"$base".fastq.gz > $PATH_SAMPLE_OUTPUT/"$base".fastq.gz;

done



#El script de limpieza:
#!/bin/bash

CUTADAPT=/home/paula/.local/bin/cutadapt
PRINSEQ=/usr/local/bin/prinseq-lite.pl
AUTOADAPT=/home/paula/programas/autoadapt-master/autoadapt.pl
PATH_RAW_SAMPLE=/datos/Pseudomonas_HGral/raw_data/fastq-merged

#Cleaning
cd $PATH_RAW_SAMPLE;
gzip -d *.gz
mkdir ./autoadapt;
for i in ./*_R1_001.fastq;do 
x=`echo $i | sed 's/_R1_001.fastq//' `;
$AUTOADAPT --threads=8 --quality-cutoff=20 --minimum-length=50 "$x"_R1_001.fastq ./autoadapt/"$x"_1_notag.fastq "$x"_R2_001.fastq ./autoadapt/"$x"_2_notag.fastq;
done 1>autoadapt/cutadapt.log
#como funciona autoadapt mejor, seguimos con prinseq
cd ./autoadapt;
#mkdir ./prinseq;
cd ./prinseq;
for i in ../*_1_notag.fastq;do 
x=`echo $i | sed 's/_1_notag.fastq//' `;
perl $PRINSEQ -fastq "$x"_1_notag.fastq -fastq2 "$x"_2_notag.fastq -min_len 50 -trim_left 10 -trim_qual_right 30 -trim_qual_type mean -trim_qual_window 20 -out_good "$x"_trimmed;
done 1>prinseq.log


