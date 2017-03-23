library(clusterCrit)
############################################################################################
# Dado un conjunto de variables y observaciones, se realiza la agrupación (k-means) de 
# las observaciones
get_clusters <- function( l_matrix, num_clusters ) {
  temp_clusters <- lapply(1:length(l_matrix), function(i) {
    kc <- kmeans(l_matrix[[i]], num_clusters[[i]], 30, 10)
    as.integer(kc$cluster)
  })
  return(temp_clusters)
}

############################################################################################
# Definición del SSGA
# Función para inicializar la población con valores aleatorios uniformemente distribuidos
init_pop <- function( pop_size, num_genes ){
  t( sapply(1:pop_size, function(s) { as.logical(round(runif(num_genes))) } ) )
}

# Selección de un individuo por torneo binario
binary_tournament <- function( population, fitness ) {
  pos <- sample(nrow(population), 2)
  if( fitness[pos[1]] < fitness[pos[2]] ) {
    return(population[pos[1],])
  } else {
    return(population[pos[2],])
  }
}

# Cruce de dos individuos en un solo punto
spx <- function( probability, ind1, ind2 ) {
  if( probability < runif(1)) {
    if( 0.5 < runif(1) ) {
      return(ind1)
    } else {
      return(ind2)
    }
  } 
  pos <- sample( (length(ind1)-1) , 1)
  return( c(ind1[1:pos], ind2[(pos+1):length(ind1)]) )
}

# Mutación de un individuo
mutation <- function( probability, individual ) {
  probs <- runif(length(individual))
  individual[ which(probs<probability) ] <- !( individual[ which(probs<probability) ] )
  return(individual)
}

# Generación del offspring
get_offspring <- function( pop_in, fitness, offspring_size, prob_crossover, prob_mutation ) {
  pop_out <- c()
  for( index in 1:offspring_size ) {
    temp <- spx(prob_crossover, binary_tournament(pop_in, fitness), binary_tournament(pop_in, fitness))
    temp <- mutation(prob_mutation, temp)
    pop_out <- rbind( pop_out, temp)
  }
  return(pop_out)
}

# Evaluación de un individuo
evaluate_individual <- function( individual, list_matrix, ground_truth_clusters, num_clusters ) {
  # seleccionamos los valores que correspondan
  l_matrix <- lapply(list_matrix, function(s) { s[,individual] })
  clusters <- get_clusters(l_matrix, num_clusters )
  cluster_fitness <- sapply(1:length(clusters), function(s) {
    extCriteria(ground_truth_clusters[[s]], clusters[[s]], "ra")
  })
  cluster_fitness_norm <- (sum( as.numeric(cluster_fitness) ) / length(clusters))**2
  length_fitness <- 1 - (sum(individual*1)/length(individual))
  fitness <- 0.8*cluster_fitness_norm + 0.2*length_fitness
  return(fitness)
}

# Función de reemplazo de la población
replace_population <- function( pop, offspring, fitness_pop, fitness_offspring) {
  new_pop <- rbind( pop[-which(fitness_pop==min(fitness_pop))[1],], offspring)
  new_fitness <- c( fitness_pop[-which(fitness_pop==min(fitness_pop))[1]], fitness_offspring)
  return(list(pop = new_pop, fitness = new_fitness))
}

# Definimos el algoritmo SSGA
ga_cluster_similarity <- function(num_genes, pop_size, prob_mutation, prob_crossover, max_eval, 
                                  list_matrix, ground_clusters, num_clusters) {
  # Inicializamos la población
  pop <- init_pop(pop_size, num_genes)
  # Calculamos el fitness de la población inicial
  fitness_pop <- sapply(1:nrow(pop), function(s) { evaluate_individual(pop[s,], list_matrix, ground_clusters, num_clusters)})
  # Aumentamos el contador de evaluaciones
  eval <- pop_size
  # Obtenemos las estadísticas
  maxs <- c(max(fitness_pop))
  medians <- c(median(fitness_pop))
  sds <- c(sd(fitness_pop))
  # Ahora evolucionamos la población de manera elitista
  while( eval <= max_eval ) {
    # Generamos los candidatos (offspring)
    offspring <- get_offspring(pop, fitness_pop, 1, prob_crossover, prob_mutation)
    # Los evaluamos 
    fitness_offspring <- sapply(1:nrow(offspring), function(s) { evaluate_individual(offspring[s,], list_matrix, ground_clusters, num_clusters)})
    # Aumentamos el contador de evaluaciones
    eval <- eval + length(fitness_offspring)
    # Reemplazamos la población de manera elitista, preservando el mejor
    replacement <- replace_population(pop, offspring, fitness_pop, fitness_offspring)
    pop <- replacement$pop
    fitness_pop <- replacement$fitness
    # Obtenemos las estadísticas de la población
    maxs <- c( maxs, max(fitness_pop))
    medians <- c( medians, median(fitness_pop))
    sds <- c( sds, sd(fitness_pop))
  }
  # retornamos los valores
  return( list( best = pop[which(fitness_pop == max(fitness_pop))[1],], best_fitness = max(fitness_pop), best_features_size = sum(pop[which(fitness_pop == max(fitness_pop))[1],]*1), max_gen = maxs, median_gen = medians, sd_gen = sds, num_clusters = num_clusters) )
}

data_2_lmat <- function(data, metadata) {
  matrix <- data[,!colnames(data) %in% c("file_name","consumption_date")]
  l_matrix <- lapply(1:nrow(metadata), function(s) {
    matrix[which(data$file_name == metadata$file_name[s]),]
  })
  return(l_matrix)
}
