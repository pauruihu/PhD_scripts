##Incorporar N's al final del alineamiento
No todas las posiciones finales están completas porque no aparecen en el vcf, de manera que hay que completar hasta la longitud de la referencia.

```{r, engine='bash', eval=FALSE}
#!/bin/bash

#variables
alin_file=/datos/Pseudomonas_HGral/data/FASTA/HGral.fas
ref_file=/datos/Pseudomonas_HGral/data/BAM/Pseudomonas_aeruginosa_isolate_W16407_3629.fna
output_filename=HGral.aln

nt_output="$(grep -v ">" $ref_file | wc | awk '{print $3-$1}')" #conteo nt

mkdir ./alineamiento_Ns
cd ./alineamiento_Ns

echo -e "\e[105mProcesando el alineamiento $alin_file con referencia de $nt_output nt\e[49m"

awk '/^>/ {OUT=substr($0,2) ".fa"}; {print >> OUT; close(OUT)}' $alin_file #split de las secuencias del alineamiento

c="n"

for i in ./*.fa; do
  nt_file="$(grep -v ">" $i | wc | awk '{print $3-$1}')"; #conteo nt muestra
	if [[ "$nt_file" < "$nt_output" ]]; then
		echo -e "Incorporando ns a $i"
		ns=$(($nt_output-$nt_file)) #ns totales necesarias
		APPENDns=$(printf ''$c'%.0s' $(seq 1 $ns)) #repite "n" (almacenado en c) tantas veces como la variable "ns" sea... y las incorpora al final del archivo
		echo "$(cat $i)$APPENDns" > $i
	fi
done

echo -e "\e[105mEscribiendo alineamiento en $output_filename\e[49m"
cat *.fa > "$output_filename"

rm *.fa


##Enmascarado repeticiones
#Primero hay que buscarlas en la referencia utilizada para este dataset.

cd ./VCF
repeat-match -f Pseudomonas_aeruginosa_isolate_W16407_3629.fna > repeats_W16407.csv
#eliminar primera línea del output (con editor de texto!)
#lanzar conversión a embl con el script transformar_repeat_embl.R

cd ../alineamiento_Ns
python /datos/Pseudos_Elche/remove_blocks_from_aln.py -a HGral.aln -t ../VCF/repeats_W16407.embl -o HGral_norep.aln -s X


