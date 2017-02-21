#!/usr/bin/env Rscript
rm(list = ls())
library(clusterCrit)
library(FSelector)
set.seed(1)

############################################################################################
# Obtención de los datos
meta <- read.table("meta.txt",sep="\t")
data <- read.table("data.txt",sep="\t")

select <- c(37,5,3,40,56,36,33,30,60,28,64,32,13,14,54,23,9,59,63,39,55,24,51,19,21,8,61,62,10,45)
select <- setdiff(1:64,select)

############################################################################################


f_selection <- function(raw_data, raw_metadata, matrix, selection) {
  num_clusters <- 3
  
  # Consideramos que la "verdad" se obtiene al realizar la agrupación utilizando todas las variables
  set.seed(1)
  ground_clusters <- lapply(1:nrow(raw_metadata), function(s) {
    temp <- matrix[which(raw_data$file_name == raw_metadata$file_name[s]),]
    kc <- kmeans(temp, num_clusters, 30, 10)
    df <- data.frame(temp,as.integer(kc$cluster))
    colnames(df) <- c(colnames(matrix),"cluster")
    df
  })
  
  # generamos una gran matrix que contiene el cluster asignado a cada día
  cluster_matrix <- do.call("rbind", ground_clusters)
  
  # usando cfs obtenemos los atributos más relevantes
  time_beg_cfs <- Sys.time()
  cfs_subset <- cfs( cluster~., cluster_matrix)
  time_end_cfs <- Sys.time()
  
  # seleccionamos los atributos más relevantes
  new_matrix <- as.matrix(matrix[ ,which(colnames(matrix) %in% cfs_subset) ])
  cfs_clusters <- lapply(1:nrow(raw_metadata), function(s) {
    temp <- new_matrix[which(raw_data$file_name == raw_metadata$file_name[s]),]
    if(length(unique(temp))<num_clusters) { 
      kc <- kmeans(temp, length(unique(temp)), 30, 10) 
    } else {
      kc <- kmeans(temp, num_clusters, 30, 10)
    }
    as.integer(kc$cluster)
  })
  
  cfs_cluster_fitness <- sapply(1:nrow(raw_metadata), function(s) {
    extCriteria(ground_clusters[[s]][,"cluster"], cfs_clusters[[s]], "ra")
  })
  cfs_cluster_fitness_norm <- (sum( as.numeric(cfs_cluster_fitness) ) / length(cfs_cluster_fitness))**2
  cfs_length_fitness <- 1 - length(cfs_subset)/ncol(matrix)
  cfs_fitness <- 0.8*cfs_cluster_fitness_norm + 0.2*cfs_length_fitness
  
  # usando information gain obtenemos los atributos más relevantes
  time_beg_ig <- Sys.time()
  ig_weights <- symmetrical.uncertainty(cluster~., cluster_matrix)
  ig_subset <- cutoff.biggest.diff(ig_weights)
  time_end_ig <- Sys.time()
  
  # seleccionamos los atributos más relevantes
  new_matrix <- as.matrix(matrix[ ,which(colnames(matrix) %in% ig_subset) ])
  ig_clusters <- lapply(1:nrow(raw_metadata), function(s) {
    temp <- new_matrix[which(raw_data$file_name == raw_metadata$file_name[s]),]
    if(length(unique(temp))<num_clusters) { 
      kc <- kmeans(temp, length(unique(temp)), 30, 10) 
    } else {
      kc <- kmeans(temp, num_clusters, 30, 10)
    }
    as.integer(kc$cluster)
  })
  
  ig_cluster_fitness <- sapply(1:nrow(raw_metadata), function(s) {
    extCriteria(ground_clusters[[s]][,"cluster"], ig_clusters[[s]], "ra")
  })
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
  f_selection(r_data, r_metadata, r_matrix, s)
})
