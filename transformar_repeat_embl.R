repeats <- read.csv("repeats_PAO1.csv", header = TRUE, sep = "")

#una posibilidad es generar un nuevo data frame a partir de este...
#lo que debe hacer es tomar la posición start1 y sumarle el número de posiciones
#indicado en la misma fila y lo mismo para start2, de forma que en el nuevo
#data frame se vayan generando intervalos por cada elemento startX
#después será necesario limpiar los duplicados porque es posible que 
#se referencie en start1 varias veces la misma posición al ser una comparativa...

df_embl <- data.frame() #data frame donde almacenar el nuevo formato

#las primeras columnas mejor al final...
col3_embl <- c() #tercera columna del data con el intervalo 


####Start1####
col3a_s1 <- c() #primer num del intervalo
col3b_s1 <- c() #segundo num del intervalo

for (i in 1:length(repeats$Start1)){
  #no es necesario is.factor TRUE o FALSE porque con que haya 1 elemento con letra,
  #lo son todos, por lo que no sirve!!
  if (grepl("r", repeats$Start1[i])==FALSE){ #toma los que no tengan r
    num <- as.numeric(as.character(repeats$Start1[i])) #así nos aseguramos de que lo 
    #toma como número aunque haya r's que conviertan el listado en factores
    col3a_s1 <- c(col3a_s1, num) #adición al vector num1, no reescritura!
    col3b_s1 <- c(col3b_s1, num + repeats$Length[i]) #adición al otro vector num2
  }
  
  
  #quito las referencias en reverse porque para enmascarar no va a hacer falta
  #if (is.factor(repeats$Start1[i])=="TRUE"){ no hace falta pero para un futuro...
  #hay regiones que acaban en r (cadena reverse!)
  #  num_char <- strsplit(as.character(repeats$Start1[i]), "r") #hacerlo caracter para quitar la r
  #  num <- as.numeric(num_char) #transformar a num para poder hacer la suma
  #  col3a_s1 <- c(col3a_s1, paste(num, "r", sep = ""))
  #  col3b_s1 <- c(col3b_s1, paste((num + repeats$Length[i]), "r", sep = "")) #devolver la referencia a reverse!
  #}
}
col3_s1 <- paste(col3a_s1, col3b_s1, sep = "..") #intervalos de la columna start1

####Start2####
col3a_s2 <- c() 
col3b_s2 <- c() 

for (i in 1:length(repeats$Start2)){
  #no es necesario is.factor TRUE o FALSE porque con que haya 1 elemento con letra,
  #lo son todos
  if (grepl("r", repeats$Start2[i])==FALSE){
    num <- as.numeric(as.character(repeats$Start2[i]))
    col3a_s2 <- c(col3a_s2, num) 
    col3b_s2 <- c(col3b_s2, num + repeats$Length[i]) 
  }
}
col3_s2 <- paste(col3a_s2, col3b_s2, sep = "..") #intervalos de la columna start2

col3_embl <- c(col3_s1, col3_s2) #última columna del data frame es la suma de los 2 vectores
row_num_embl <- length(col3_embl) #sabiendo el num filas podemos incorporar el 
#número adecuado de repeticiones de las primeras 2 columnas del embl.

#creamos un vector repetitivo de la longitud del num filas
col1_embl <- rep_len("FT  ", row_num_embl)
col2_embl <- rep_len("misc_feature   ", row_num_embl)

### Generar el data frame con todos los datos ###
df_embl <- data.frame(col1_embl, col2_embl, col3_embl)
df_embl_unique <- unique.data.frame(df_embl) #eliminar duplicados

#sacar el archivo
write.table(df_embl_unique, file = "repeats_PAO1.embl", row.names = FALSE, quote = FALSE, append = FALSE, col.names = FALSE)