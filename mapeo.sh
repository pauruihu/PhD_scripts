##Mapeo
Utilizamos la referencia Pseudomonas_aeruginosa_isolate_W16407_3629.fna de ST244, el mayoritario en este dataset.

```{r, engine='bash', eval=FALSE}
#!/bin/bash

#PATHS PROGRAMAS
BWA=/home/paula/programas/bwa-0.7.12/bwa
SAMTOOLS=/home/paula/programas/samtools-1.4/samtools
PATH_PICARD=/home/paula/programas/picard-tools-1.119
GATK=/home/paula/programas/GenomeAnalysisTK.jar

#PARA CAMBIAR
REFERENCE=Pseudomonas_aeruginosa_isolate_W16407_3629.fna
PREFIX_REF=W16407
PATH_cleanedfastq=/datos/Pseudomonas_HGral/data/fastq_cleaned-merged/autoadapt/prinseq

#-R en bwa podemos incorporar el Read Group necesario para que no nos dé error el GATK luego!

mkdir ./BWA
cd ./BWA
cp /datos/Pseudomonas_HGral/genomas_ref/fna/group4/Pseudomonas_aeruginosa_isolate_W16407_3629.fna .

#indexados varios de la referencia
$BWA index -p $PREFIX_REF -a is $REFERENCE
java -jar $PATH_PICARD/CreateSequenceDictionary.jar R= $REFERENCE O= Pseudomonas_aeruginosa_isolate_W16407_3629.dict #SI CAMBIAS REF, CAMBIA EL OUTPUT
$SAMTOOLS faidx $REFERENCE 

for i in /datos/Pseudomonas_HGral/data/fastq_cleaned-merged/autoadapt/prinseq/*_1.fastq; do
x=`echo $i | sed 's/\/datos\/Pseudomonas_HGral\/data\/fastq_cleaned-merged\/autoadapt\/prinseq\///' | cut -f 1 -d "_" `;
z=`echo $i | sed 's/\/datos\/Pseudomonas_HGral\/data\/fastq_cleaned-merged\/autoadapt\/prinseq\///' | sed 's/_1.fastq//'`;
echo -e "\e[105mmapeo de la muestra "$x" con bwa-mem\e[49m";
$BWA mem $PREFIX_REF $PATH_cleanedfastq/"$z"_1.fastq $PATH_cleanedfastq/"$z"_2.fastq > "$x"_mem.sam
echo -e "\e[105mbam ordenado e indexado de la muestra "$x" con samtools\e[49m";
$SAMTOOLS view -S "$x"_mem.sam -b -o "$x"_mem.bam;
$SAMTOOLS sort "$x"_mem.bam -o sorted_mem_"$x".bam;
$SAMTOOLS index sorted_mem_"$x".bam;
rm "$x"_mem.bam "$x"_mem.sam;

#si se nos ha olvidado el -r en bwa, habrá que añadirse el RG a posteriori con picard-tools
echo -e "\e[105mAdición RG de la muestra "$x" y alineacion de SNPs\e[49m";
picard-tools AddOrReplaceReadGroups I= sorted_mem_"$x".bam O= sorted_RG_mem_"$x".bam SORT_ORDER=coordinate RGID=foo RGLB=bar RGPL=illumina RGSM=Sample RGPU=NONE CREATE_INDEX=True;
rm sorted_mem_"$x".bam sorted_mem_"$x".bam.bai;
java -Xmx8g -jar $PATH_PICARD/MarkDuplicates.jar INPUT=sorted_RG_mem_"$x".bam OUTPUT="$x".dedup.bam METRICS_FILE="$x".metrics REMOVE_DUPLICATES=true;
$SAMTOOLS index "$x".dedup.bam;
java -jar $GATK -T RealignerTargetCreator -R $REFERENCE -I "$x".dedup.bam -o forIndelRealigner.intervals;
#this produce: A list of target intervals to pass to the IndelRealigner. 
java -jar $GATK -T IndelRealigner -R $REFERENCE -I "$x".dedup.bam -targetIntervals forIndelRealigner.intervals -o "$x".align_dedup.bam;
rm "$x".dedup.bam "$x".dedup.bam.bai "$x".dedup.bai sorted_RG_mem_"$x".bam sorted_RG_mem_"$x".bai

done
```

