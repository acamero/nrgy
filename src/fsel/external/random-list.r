rm(list=ls())
library(clValid)
# Cargamos el código del algoritmo
source("ssga.r")

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
random_search <- function(raw_data, raw_metadata, select, seed) {
  raw_data_t <- raw_data[which(raw_data$file_name %in% raw_metadata$file_name[select]),]
  raw_metadata_t <- raw_metadata[select,]
  # Convertimos los datos al formato de entrada del algoritmo
  list_matrix_con <- data_2_lmat(raw_data_t,raw_metadata_t)
  # Número de clusters
  num_clusters <- optimal_clus(list_matrix_con)
  # obtenemos la "verdad"
  set.seed(1)
  ground_clusters <- get_clusters( list_matrix_con, num_clusters )
  
  # El número de genes corresponde a la cantidad de observaciones de un día
  num_genes <- ncol(list_matrix_con[[1]])
  # Generamos una serie de individuos aleatorios
  time_beginning <- Sys.time()
  set.seed(seed)
  pop <- init_pop(1,num_genes)
  time_end <- Sys.time()
  # Evaluamos
  fitness <- evaluate_individual(pop[1,], list_matrix_con, ground_clusters, num_clusters)
  
  results <- list(individual = pop[1,], fitness = fitness, num_clusters = num_clusters)
  dir.create(as.character(select))
  
  # Guardamos los resultados
  #file <- paste(seed,"results-rand.RData", sep="-")
  file <- paste(1,"results-rand.RData", sep="-")
  file <- paste(select,"/",file, sep="")
  save(results, time_beginning, time_end, file=file)
}


# Elegimos una semilla por defecto
seed <- 1
# Revisamos si se ha pasado una nueva semilla por línea de comandos
args <- commandArgs(trailingOnly = TRUE)
if (length(args)==1) {
  seed <- as.integer(args[1])
}

# Cargamos los datos
metadata <- read.table("meta.txt",sep="\t")
data <- read.table("data.txt",sep="\t")

#lapply(2:30, function (s) { random_search(data, metadata, 16, s) })
lapply(1:64, function (s) { random_search(data, metadata, s, s) })
