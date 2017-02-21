rm(list=ls())
# Cargamos el código del algoritmo
source("ssga.r")
# Cargamos los datos
raw_metadata <- read.table("meta.txt",sep="\t")
raw_data <- read.table("data.txt",sep="\t")

#######################################################################################
# En este bloque seleccionamos edificios de manera arbitraria
# IES
#select <- c(23,61)
# Centros de salud y hospitales
#select <- c(16,22,28,29,30,34,53,56,58,59,60,63)
# Centros de salud
#select <- c(16,28,29,30,34)
select <- c(16)
raw_data <- raw_data[which(raw_data$file_name %in% raw_metadata$file_name[select]),]
raw_metadata <- raw_metadata[select,]
#######################################################################################

# Convertimos los datos al formato de entrada del algoritmo
list_matrix_con <- data_2_lmat(raw_data,raw_metadata)
# Número de clusters
num_clusters <- 3
# obtenemos la "verdad"
set.seed(1)
ground_clusters <- get_clusters( list_matrix_con, num_clusters )

# El número de genes corresponde a la cantidad de observaciones de un día
num_genes <- ncol(list_matrix_con[[1]])
# Generamos una serie de individuos aleatorios
pop <- init_pop(30,num_genes)

# Elegimos una semilla por defecto
seed <- 1
# Revisamos si se ha pasado una nueva semilla por línea de comandos
args <- commandArgs(trailingOnly = TRUE)
if (length(args)==1) {
  seed <- as.integer(args[1])
}
set.seed(seed)

############################################################################################
time_beginning <- Sys.time()
fitness_pop <- sapply(1:nrow(pop), function(s) { 
  evaluate_individual(pop[s,], list_matrix_con, ground_clusters, num_clusters)
})
time_end <- Sys.time()
############################################################################################

file <- paste(seed,"results-rand.RData", sep="-")
save(fitness_pop, pop, time_beginning, time_end, file=file)
 
 