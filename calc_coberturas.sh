##Cálculo de la cobertura
}
#!/bin/bash

REFERENCE=/datos/Pseudomonas_HGral/genomas_ref/fna/group4/Pseudomonas_aeruginosa_isolate_W16407_3629.fna

cd ./BAM;

for i in /datos/Pseudomonas_HGral/data/BWA/*.align_dedup.bam; do
  x=`echo $i | sed 's/\/datos\/Pseudomonas_HGral\/data\/BWA\///' | sed 's/.align_dedup.bam//' `;
	
	echo "Coverage "$x"" >> cobertura_media_HGral.txt
	#samtools depth $i  |  awk 'BEGIN {FS="\t"}; {sum+=$3; sumsq+=$3*$3} END { print "Average = ",sum/NR; print "Stdev = ",sqrt(sumsq/NR - (sum/NR)**2)}' >> cobertura_media_HGral.txt
	samtools depth $i  |  awk '{sum+=$3; sumsq+=$3*$3} END { print "Average = ",sum/NR; print "Stdev = ",sqrt(sumsq/NR - (sum/NR)**2)}' >> cobertura_media_HGral.txt

	# plot per base coverage:

	bedtools genomecov -dz -ibam $i -g $REFERENCE > "$x".align_dedup.bam.bed
		    
	echo 'data <- read.table(file="'$x'.align_dedup.bam.bed", header=F)'> plot_cov.R # read data
	echo 'pdf("'$x'.coverage_plot.pdf")'>> plot_cov.R # open pdf file
	echo 'hist(data[,3], xlab="Coverage", col="blue", main="Coverage distribution graph")'  >> plot_cov.R # histogram
	echo "dev.off()" >> plot_cov.R # close pdf file

	R --vanilla < plot_cov.R
done

##CALCULO
#media cobertura
echo "Mean Coverage HGral" > coverage_average.txt;
cat cobertura_media_HGral.txt | grep "Average" | cut -f 4 -d " " | awk '{ total += $1 } END { print total/NR }' >> coverage_average.txt;
#mediana cobertura
echo "Median Coverage HGral" >> coverage_average.txt;
cat cobertura_media_HGral.txt | grep "Average" | cut -f 4 -d " " | sort -g | awk ' { a[i++]=$1; } END { print a[int(i/2)]; }' >> coverage_average.txt;
