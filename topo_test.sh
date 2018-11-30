#!/bin/bash
for i in *_aln.fas.treefile; do
x=`echo $i | cut -f 1-2 -d "." `;
y=`echo $i | cut -f 1-2 -d "_" `;
cat $i ../../Elche_brote_core_genes.treefile > arboles_core_y_"$y";
iqtree -nt 1 -s "$x" -m GTR+G4 -z arboles_core_y_"$y" -zb 10000 -zw -au > "$y"_topology;
done


