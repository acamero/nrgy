rm(list=ls())
library(clValid)
# Cargamos el código del algoritmo
source("ssga.r")
# Cargamos los datos
raw_metadata <- read.table("meta.txt",sep="\t")
raw_data <- read.table("data.txt",sep="\t")

#######################################################################################
# Definimos una función auxiliar que retorna la moda estadística
val_mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}

optimal_clus <- function(list_ch) {
  set.seed(1)
  n_clust <- c(2:10)
  ivs <- lapply(list_ch, function(lt) {
    clValid(lt, n_clust, clMethods=c("kmeans"), validation="internal", maxitems=1000)
  })
  sel_measures <- c("Connectivity", "Dunn", "Silhouette")
  oss <- lapply(ivs, function(iv) { optimalScores(iv, measures = sel_measures) })
  num_clusters <- lapply(oss, function(os) { as.numeric(as.character(val_mode(os$Clusters))) })
  return(num_clusters)
}

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

list_matrix_con <- data_2_lmat(raw_data,raw_metadata)
# Definimos los parámetros para el algoritmo
# El número de genes corresponde a la cantidad de observaciones de un día
num_genes <- ncol(list_matrix_con[[1]])
# Tamaño de la población
pop_size <- 10
# Probabilidad de mutación
prob_mutation <- 1 / num_genes
# Probabilidad de crossover
prob_crossover <- 0.8
# Número máximo de evaluaciones
max_eval <- 1000
# Número de clusters
num_clusters <- optimal_clus(list_matrix_con)
# obtenemos la "verdad"
set.seed(1)
ground_clusters <- get_clusters( list_matrix_con, num_clusters )
# Elegimos una semilla por defecto
seed <- 1
# Revisamos si se ha pasado una nueva semilla por línea de comandos
args <- commandArgs(trailingOnly = TRUE)
if (length(args)==1) {
  seed <- as.integer(args[1])
}
set.seed(seed)

#######################################################################################
# Registramos el tiempo de inicio
time_beginning <- Sys.time()
# Ejecutamos SSGA
results <- ga_cluster_similarity(num_genes, pop_size, prob_mutation, prob_crossover, max_eval, list_matrix_con, ground_clusters, num_clusters)
# Y el tiempo de término
time_end <- Sys.time()
#######################################################################################

# Guardamos los resultados
file <- paste(seed,"results-ssga.RData", sep="-")
save(results, time_beginning, time_end, file=file)