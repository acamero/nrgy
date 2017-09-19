from __future__ import division
import array
import numpy as np
import random
import tensorflow as tf
from util.def_config import *
from util.data_generation import generate_data
from util.simple_rnn import evaluate

#@article{DEAP_JMLR2012,
#    author    = " F\'elix-Antoine Fortin and Fran\c{c}ois-Michel {De Rainville} and Marc-Andr\'e Gardner and Marc Parizeau and Christian Gagn\'e ",
#    title     = { {DEAP}: Evolutionary Algorithms Made Easy },
#    pages    = { 2171--2175 },
#    volume    = { 13 },
#    month     = { jul },
#    year      = { 2012 },
#    journal   = { Journal of Machine Learning Research }
#}
from deap import creator, base, tools, algorithms

# TODO parameters!
# lstm_size, num_layers, keep_prob, input_size, num_steps
RANGES = [(1,1024), (1,1024), (1,100), (1,1024), (1,1024)]


#########################################################################################################################
# Fitness cache. If an individual has been evaluated, the fitness is returned.
_CACHE = {}
def upsert_cache(config, fitness):
    if fitness:
        _CACHE[str(config)] = fitness
        return _CACHE[str(config)]
    elif str(config) in _CACHE:
        return _CACHE[str(config)]
    return None

#########################################################################################################################

# Convert an individual into a NN configuration
def decode_individual(individual):
    config = Config()
    config.lstm_size = individual[0]
    config.num_layers = individual[1]
    config.keep_prob = float(individual[2]/100)
    config.input_size = individual[3]
    config.num_steps = individual[4]
    return config

# Initialize an individual using int encoding and [low,high) ranges
def init_individual(clazz, ranges):
    return clazz(np.random.randint(*p) for p in ranges)

# Calculate the std from the width of the ranges
def _std_from_ranges(ranges):
    # TODO improve
    return [(r[1]-r[0])*.01 for r in ranges]


# Gaussian mutation
def gaussian_mutation(individual, ranges, stds):
    prob = 1/len(individual)
    for pos, ran, std in zip(range(len(individual)), ranges, stds):
        if np.random.rand() < prob:
            individual[pos] = int(round(np.random.normal( individual[pos], std)))
            if individual[pos] < ran[0]:
                individual[pos] = ran[0]
            elif individual[pos] >= ran[1]:
                individual[pos] = ran[1] - 1
            #
        #
    #
    return individual

# Evaluate the NN represented by the individual
def evaluate_individual(individual):
    config = decode_individual(individual)
    fitness = upsert_cache(config, None)
    #print("Fitness from cache:",fitness)
    if not fitness:
        #print("Evaluate", str(config))
        dataset = generate_data(config, experiment)
        loss, no_vars = evaluate(dataset, config, experiment, predicts=False)
        fitness = [loss, no_vars]
        #fitness = [np.random.rand(), np.random.rand()]
        upsert_cache(config, fitness)
    print("Configuration", str(config), "Fitness", fitness)  
    return fitness

#########################################################################################################################

# By default 2 objectives (FO-1: minimize training error, FO-2: minimize the number of training variables)
def init_problem(individual_ranges, fos=[-1.0, -1.0]):
    creator.create("FitnessMulti", base.Fitness, weights=fos)
    creator.create("Individual", list, fitness=creator.FitnessMulti)
    toolbox = base.Toolbox()
    toolbox.register("individual", init_individual, clazz=creator.Individual, ranges=individual_ranges)
    toolbox.register("population", tools.initRepeat, list, toolbox.individual)
    toolbox.register("evaluate", evaluate_individual)
    toolbox.register("mate", tools.cxOnePoint)
    toolbox.register("mutate", gaussian_mutation, ranges=individual_ranges, stds=_std_from_ranges(individual_ranges))
    toolbox.register("select", tools.selNSGA2)
    # Version 1.1 toolbox.register("select", tools.selNSGA2, nd='standard')
    toolbox.register("kbest", tools.selBest)
    # Version 1.1 toolbox.register("kbest", tools.selBest, fit_attr='fitness')
    return toolbox

#########################################################################################################################

def main(seed=1, pop_size=5, offspring_size=1, NGEN = 2, CXPB=0.8, MUTPB=0.1, expt=DEFAULT_EXPERIMENT):
    global experiment 
    experiment = expt
    np.random.seed(seed)
    tf.set_random_seed(seed)
    random.seed(seed)
    # initialize the problem using default objetives
    toolbox = init_problem(RANGES)
    pop = toolbox.population(n=pop_size)
    # Evaluate the entire population
    fitnesses = list(map(toolbox.evaluate, pop))
    for ind, fit in zip(pop, fitnesses):
        ind.fitness.values = fit
        print( ind, fit)
    # Begin the evolution
    for g in range(NGEN):
        print("-- Generation %i --" % g)
        # Select the next generation individuals
        if offspring_size > 1:
            offspring = toolbox.select(pop, offspring_size)
        else:
            offspring = toolbox.select(pop, 2)
        # Clone the selected individuals
        offspring = list(map(toolbox.clone, offspring))
        # Apply crossover and mutation on the offspring
        for child1, child2 in zip(offspring[::2], offspring[1::2]):
            if np.random.rand() < CXPB:
                toolbox.mate(child1, child2)
                del child1.fitness.values
                del child2.fitness.values
        # for
        for mutant in offspring:
            if np.random.rand() < MUTPB:
                toolbox.mutate(mutant)
                del mutant.fitness.values
        # for
        # Evaluate the individuals with an invalid fitness
        invalid_ind = [ind for ind in offspring if not ind.fitness.valid]
        fitnesses = map(toolbox.evaluate, invalid_ind)
        for ind, fit in zip(invalid_ind, fitnesses):
            ind.fitness.values = fit
        # for
        # Replacement
        if offspring_size > 1:
            pop[:] = toolbox.kbest(pop, pop_size-offspring_size) + offspring
        else:
            pop[:] = toolbox.kbest(pop, pop_size-1) + toolbox.select(offspring, 1)
        # Gather all the fitnesses in one list and print the stats
        for ind in pop:
            print(ind, ind.fitness.values)
        fits = [ind.fitness.values for ind in pop]
        _mean = np.mean(fits, axis=0)
        _median = np.median(fits, axis=0)
        _min = np.min(fits, axis=0)
        _max = np.max(fits, axis=0)
        _std = np.std(fits, axis=0)
        print("  Min %s" % _min)
        print("  Max %s" % _max)
        print("  Avg %s" % _mean)
        print("  Med %s" % _median)
        print("  Std %s" % _std)



#########################################################################################################################

if __name__ == '__main__':
    main()

