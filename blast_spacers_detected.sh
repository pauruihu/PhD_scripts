#!/bin/bash

for i in ./P*/result.out; do 
	x=`echo $i | cut -d '/' -f 2 `;
	cd /datos/CRISPR/"$x";
	blastn -query /datos/CRISPR/spacers_detected_first_report.fas -task 'blastn' -db blastdb -out ./"$x"_spacers_detected.out -evalue 0.1 -outfmt 7 -num_alignments 5 -word_size 7 -gapopen 3 -gapextend 2 -reward 1 -penalty -1; 
	cd ..
done

