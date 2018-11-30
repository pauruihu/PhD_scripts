### determinar coverage (posiciones respecto referencia)
#(verlo en el alineamiento de las secuencias sin eliminar repeticiones!!!)
#En R
library(ape)
fas <- read.dna("HGral.aln", "fasta", as.character = TRUE)
seq_names_Elche <- rownames(fas)

n.frame <- data.frame("seq", "num_n", "coverage", stringsAsFactors=FALSE)
for (i in 1:length(fas[,1])){
  is.n <- c()
  seq_dna <- fas[i,]
  is.n <- which(seq_dna=="n")
  percent_n <- (length(is.n) / length(seq_dna))*100
  coverage <- 100 - percent_n
  n.frame <-rbind(n.frame, list(seq_names_Elche[i], length(is.n), coverage))
}
write.table(n.frame, file = "coverage_ns_HGral.txt", quote = FALSE, row.names = FALSE, col.names = FALSE, sep = "\t")


