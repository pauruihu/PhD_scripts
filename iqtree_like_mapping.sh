#!/bin/bash
while read line; do
	~/iqtree/iqtree -s "$line".fas -lmap 1500 -n 0 -m TEST -nt AUTO;
done < trees_from_core_genes.txt
