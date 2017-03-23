#!/usr/bin/env Rscript
rm(list = ls())
library(clValid)
library(clusterCrit)
library(FSelector)
set.seed(1)


############################################################################################
# Definimos una función auxiliar que retorna la moda estadística
val_mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}

optimal_clus <- function(lt) {
  set.seed(1)
  n_clust <- c(2:10)
  iv <- clValid(lt, n_clust, clMethods=c("kmeans"), validation="internal", maxitems=1000)
  sel_measures <- c("Connectivity", "Dunn", "Silhouette")
  os <- optimalScores(iv, measures = sel_measures) 
  num_clusters <- as.numeric(as.character(val_mode(os$Clusters))) 
  return(num_clusters)
}

############################################################################################
# Obtención de los datos
meta <- read.table("meta.txt",sep="\t")
data <- read.table("data.txt",sep="\t")

#select <- c(37,5,3,40,56,36,33,30,60,28,64,32,13,14,54,23,9,59,63,39,55,24,51,19,21,8,61,62,10,45)
#select <- setdiff(1:64,select)
select <- 1:64

############################################################################################


f_selection <- function(matrix, selection) {
  #num_clusters <- 3
  num_clusters <- optimal_clus(matrix)
  set.seed(1)
  # Consideramos que la "verdad" se obtiene al realizar la agrupación utilizando todas las variables
  kc <- kmeans(matrix, num_clusters, 30, 10)
  ground_clusters <- data.frame(matrix,as.integer(kc$cluster))
  colnames(ground_clusters) <- c(colnames(matrix),"cluster")
  
  
  # usando cfs obtenemos los atributos más relevantes
  time_beg_cfs <- Sys.time()
  cfs_subset <- cfs( cluster~., ground_clusters)
  time_end_cfs <- Sys.time()
  
  # seleccionamos los atributos más relevantes
  new_matrix <- as.matrix(matrix[ ,which(colnames(matrix) %in% cfs_subset) ])
  kc_cfs <- kmeans(new_matrix, num_clusters, 30, 10)
  cfs_clusters <- as.integer(kc_cfs$cluster)
  
  cfs_cluster_fitness <- extCriteria(ground_clusters[,"cluster"], cfs_clusters, "ra")
  
  cfs_cluster_fitness_norm <- (sum( as.numeric(cfs_cluster_fitness) ) / length(cfs_cluster_fitness))**2
  cfs_length_fitness <- 1 - length(cfs_subset)/ncol(matrix)
  cfs_fitness <- 0.8*cfs_cluster_fitness_norm + 0.2*cfs_length_fitness
  
  # usando information gain obtenemos los atributos más relevantes
  time_beg_ig <- Sys.time()
  ig_weights <- symmetrical.uncertainty(cluster~., ground_clusters)
  ig_subset <- cutoff.biggest.diff(ig_weights)
  time_end_ig <- Sys.time()
  
  # seleccionamos los atributos más relevantes
  new_matrix <- as.matrix(matrix[ ,which(colnames(matrix) %in% ig_subset) ])
  kc_ig <- kmeans(new_matrix, num_clusters, 30, 10)
  ig_clusters <- as.integer(kc_ig$cluster)

  
  ig_cluster_fitness <- extCriteria(ground_clusters[,"cluster"], ig_clusters, "ra")
  ig_cluster_fitness_norm <- (sum( as.numeric(ig_cluster_fitness) ) / length(ig_cluster_fitness))**2
  ig_length_fitness <- 1 - length(ig_subset)/ncol(matrix)
  ig_fitness <- 0.8*ig_cluster_fitness_norm + 0.2*ig_length_fitness

  results <- list( cfs_fitness= cfs_fitness, cfs_subset= cfs_subset, ig_fitness = ig_fitness, ig_subset = ig_subset) 
  
  
  # Guardamos los resultados
  dir.create(as.character(selection))
  file <- paste(1,"results-filters.RData", sep="-")
  file <- paste(selection,"/",file, sep="")
  save(results, time_beg_ig, time_end_ig, time_beg_cfs, time_end_cfs, file=file)
} 

############################################################################################


fs <- lapply(select, function(s) {
  r_data <- data[which(data$file_name == meta$file_name[s]),]
  r_metadata <- meta[s,]
  r_matrix <- r_data[,!colnames(data) %in% c("file_name","consumption_date")]
  f_selection(r_matrix, s)
})
