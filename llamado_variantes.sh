##Variant calling (relajado)

#!/bin/bash

#PATHS PROGRAMAS
BWA=/home/paula/programas/bwa-0.7.12/bwa
SAMTOOLS=/home/paula/programas/samtools-1.4/samtools
PATH_BCFTOOLS=/home/paula/programas/bcftools-1.4

#PARA CAMBIAR
REFERENCE=Pseudomonas_aeruginosa_isolate_W16407_3629.fna
PREFIX_REF=W16407

mkdir ./VCF
mkdir ./FASTA
cd ./VCF
cp /datos/Pseudomonas_HGral/data/BWA/Pseudomonas_aeruginosa_isolate_W16407_3629.fna .

#indexados varios de la referencia
$BWA index -p $PREFIX_REF -a is $REFERENCE
$SAMTOOLS faidx $REFERENCE 

for i in ../BWA/*.align_dedup.bam; do
x=`echo $i | sed 's/..\/BWA\///' | sed 's/.align_dedup.bam//'`;

#variant calling
echo -e "\e[105mvariant calling de la muestra "$x" con Q30\e[49m";
$SAMTOOLS mpileup -q 30 -Q 30 -ugf $REFERENCE $i | $PATH_BCFTOOLS/bcftools call -c --ploidy 1 -Oz -o "$x"_raw_all.vcf.gz;

#-g: proximity to indels, filter SNPs within <int> base pairs of an indel;  -G: filter clusters of indels separated by <int> or fewer base pairs allowing only one to pass;
#-e:exclude sites for which the expression is true (see man page for details)
$PATH_BCFTOOLS/bcftools filter -sLowQual -g3 -G10 \
    -i'%QUAL>20 && (DP4[2]+DP4[3])>=4 && (DP4[0]+DP4[1])/(DP4[2]+DP4[3]+DP4[0]+DP4[1])<=0.25 || %QUAL>20 && (DP4[0]+DP4[1])>=2 && (DP4[2]+DP4[3])/(DP4[0]+DP4[1]+DP4[2]+DP4[3])<=0.25' \
    "$x"_raw_all.vcf.gz -Oz -o "$x".vcf.gz;
#Cuidado: van a generarse INDELs que pasarán los filtros pero no serán indels reales, llamará a esa posición (1 nt) como idéntico a la referencia y después duplicada como indel si hay una lectura
# que la de como indel aunque la mayoría de lecturas sea igual a la referencia (extra de info inservible)

$PATH_BCFTOOLS/bcftools view -f "PASS" "$x".vcf.gz -o "$x"_goodqual.vcf; #con indels!
grep -v "INDEL" "$x"_goodqual.vcf > "$x"_gq_cns.vcf; #buenos sin indels para generar el genoma (sin desplazamientos)

$PATH_BCFTOOLS/vcfutils.pl vcf2fq "$x"_gq_cns.vcf > "$x".fq;
seqtk seq -A "$x".fq > "$x".fa;
awk '/^>/ {gsub(/.fa?$/,"",FILENAME);printf(">%s\n",FILENAME);next;} {print}' "$x".fa > "$x".fas;
rm "$x".fq "$x".fa;
mv "$x".fas ../FASTA

done

cd ../FASTA
cat *.fas /datos/Pseudomonas_HGral/data/BWA/Pseudomonas_aeruginosa_isolate_W16407_3629.fna > HGral.fas

