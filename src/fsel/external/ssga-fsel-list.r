rm(list=ls())
# Cargamos el código del algoritmo
source("ssga.r")
# Cargamos los datos
raw_metadata <- read.table("meta.txt",sep="\t")
raw_data <- read.table("data.txt",sep="\t")

#######################################################################################
# En este bloque seleccionamos edificios de manera arbitraria
# Para cada edificio se ejecutará la búsqueda de la mejor combinación de atributos
#select_list <- c(37,5,3,40,56,36,33,30,60,28,64,32,13,14,54,23,9,59,63,39,55,24,51,19,21,8,61,62,10,45)
#select_list <- setdiff(1:64,select_list)
select_list <- 1:64

#######################################################################################
execute_ssga_building <- function(raw_data, raw_metadata, select, seed) {
  raw_data_t <- raw_data[which(raw_data$file_name %in% raw_metadata$file_name[select]),]
  raw_metadata_t <- raw_metadata[select,]
  
  list_matrix_con <- data_2_lmat(raw_data_t,raw_metadata_t)
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
  num_clusters <- 3
  # obtenemos la "verdad"
  set.seed(1)
  ground_clusters <- get_clusters( list_matrix_con, num_clusters )
  # Elegimos una semilla por defecto
  set.seed(seed)
  #######################################################################################
  # Registramos el tiempo de inicio
  time_beginning <- Sys.time()
  # Ejecutamos SSGA
  results <- ga_cluster_similarity(num_genes, pop_size, prob_mutation, prob_crossover, max_eval, list_matrix_con, ground_clusters, num_clusters)
  # Y el tiempo de término
  time_end <- Sys.time()
  #######################################################################################
  
  dir.create(as.character(select))
  
  # Guardamos los resultados
  file <- paste(seed,"results-ssga.RData", sep="-")
  file <- paste(select,"/",file, sep="")
  save(results, time_beginning, time_end, file=file)
} 
 

#######################################################################################
seed <- 1
# Revisamos si se ha pasado una nueva semilla por línea de comandos
args <- commandArgs(trailingOnly = TRUE)
if (length(args)==1) {
  seed <- as.integer(args[1])
}

#lapply( select_list, function(s) { execute_ssga_building(raw_data, raw_metadata, s, seed) })

lapply( select_list, function(s) {
  for( seed in 2:30 ){
    execute_ssga_building(raw_data, raw_metadata, s, seed) 
  }
})
