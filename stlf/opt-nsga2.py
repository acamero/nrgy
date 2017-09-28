from __future__ import division
import array
import numpy as np
import random
import tensorflow as tf
import pandas
import json
import argparse
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


CACHE_FILE = 'cache.json'
# TODO parameters!
# RANGES:
#     0. lstm_size (number of cells per layer), 
#     1. num_layers (hidden layers), 
#     2. keep_prob (keep probability), 
#     3. num_steps (number of times back)
#
# Note: 'keep_prob' and 'num_steps' do not impact on the number of trainable variables
#
# If lstm_size=128 and num_layers=128 => 16,777,857 trainable variables (considering input_size=1)
#RANGES = [(1,129), (1,129), (1,101), (1,129)]
# If lstm_size=32 and num_layers=32 => 262,305 trainable variables (considering input_size=1)
#RANGES = [(1,33), (1,33), (1,101), (1,33)]
# If lstm_size=16 and num_layers=16 => 32,849 trainable variables (considering input_size=1)
RANGES = [(1,17), (1,17), (1,101), (1,17)]


########################################################################################################################
# Fitness cache. If an individual has been evaluated, the fitness is returned.
_CACHE = {}
def upsert_cache(config, fitness):
    if fitness:
        _CACHE[str(config)] = fitness
        return _CACHE[str(config)]
    elif str(config) in _CACHE:
        return _CACHE[str(config)]
    return None

def _cache_to_csv(filename):
    dj = json.dumps(_CACHE).encode('utf-8')
    try:
        with open(filename,'w') as f:
            f.write(dj)
        f.close()
        print(str(len(_CACHE)) + ' cache entries saved')
    except IOError:
        print('Unable to store the cache')

def _load_cache(filename):
    try:
        with open(filename, 'r') as f:
            global _CACHE
            f_str = f.read()
            _CACHE = json.loads(f_str)
            print(str(len(_CACHE)) + ' entries loaded into the cache memory')
        f.close()
    except IOError:
        print('Unable to load the cache')


#########################################################################################################################

# Convert an individual into a NN configuration
def decode_individual(individual):
    config = Config()
    config.lstm_size = individual[0]
    config.num_layers = individual[1]
    config.keep_prob = float(individual[2]/100)
    config.num_steps = individual[3]
    return config

# Initialize an individual using int encoding and [low,high) ranges
def init_individual(clazz, ranges):
    return clazz(np.random.randint(*p) for p in ranges)

# Calculate the std from the width of the ranges
def _std_from_ranges(ranges, factor=0.01):
    if factor <= 0:
        return [1 for _ in ranges]
    return [(r[1]-r[0])*factor for r in ranges]


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
    print("Evaluate", str(config))
    if not fitness:
        dataset = generate_data(config, experiment)
        loss, no_vars = evaluate(dataset, config, experiment, predicts=False)
        fitness = [float(loss), float(no_vars)]
        #fitness = [np.random.rand(), np.random.rand()]
        upsert_cache(config, fitness)
    print("Fitness", fitness)  
    return fitness

#########################################################################################################################

# By default 2 objectives (FO-1: minimize training error, FO-2: minimize the number of training variables)
def init_problem(individual_ranges, std_factor, fos=[-1.0, -1.0]):
    creator.create("FitnessMulti", base.Fitness, weights=fos)
    creator.create("Individual", list, fitness=creator.FitnessMulti)
    toolbox = base.Toolbox()
    toolbox.register("individual", init_individual, clazz=creator.Individual, ranges=individual_ranges)
    toolbox.register("population", tools.initRepeat, list, toolbox.individual)
    toolbox.register("evaluate", evaluate_individual)
    toolbox.register("mate", tools.cxOnePoint)
    toolbox.register("mutate", gaussian_mutation, ranges=individual_ranges, stds=_std_from_ranges(individual_ranges, std_factor))
    toolbox.register("select", tools.selNSGA2)
    #toolbox.register("select", tools.selTournament, tournsize=3)
    # Version 1.1 toolbox.register("select", tools.selNSGA2, nd='standard')
    toolbox.register("kbest", tools.selBest)
    # Version 1.1 toolbox.register("kbest", tools.selBest, fit_attr='fitness')
    return toolbox

#########################################################################################################################

def main(seed, pop_size, offspring_size, NEV, CXPB, MUTPB, expt, file_name, std_factor):
    print("seed", seed, "pop_size", pop_size, "offspring", offspring_size,
            "NEV", NEV, "CXPB", CXPB, "MUTPB", MUTPB, "expt", str(expt), 
            "file_name", file_name, "std_factor", std_factor)
    global experiment 
    experiment = expt
    np.random.seed(seed)
    tf.set_random_seed(seed)
    random.seed(seed)
    # Initialize the problem using default objetives
    toolbox = init_problem(RANGES, std_factor)
    # Initialize statistics
    stats = tools.Statistics(key=lambda ind: ind.fitness.values)
    stats.register("avg", np.mean, axis=0)
    stats.register("med", np.median, axis=0)
    stats.register("std", np.std, axis=0)
    stats.register("min", np.min, axis=0)
    stats.register("max", np.max, axis=0)
    # Initialize the logger
    logbook = tools.Logbook()
    # Initialize population
    pop = toolbox.population(n=pop_size)
    # Evaluate the entire population
    fitnesses = list(map(toolbox.evaluate, pop))
    for ind, fit in zip(pop, fitnesses):
        ind.fitness.values = fit
    # Gather the stats
    record = stats.compile(pop)
    print(record)
    evals = pop_size
    logbook.record(evaluations=evals, gen=0, **record)
    g = 1
    # Begin the evolution
    while evals < NEV:
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
        if offspring_size == 1:  
            offspring = [offspring[0]]
        #
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
        pop[:] = toolbox.kbest(pop, pop_size-offspring_size) + offspring
        # Gather the stats
        record = stats.compile(pop)
        print(record)
        evals = evals + offspring_size
        g += 1
        logbook.record(evaluations=evals, gen=g, **record)
    # for
    df = pandas.DataFrame(data=logbook)
    df.to_csv(file_name, sep=';', encoding='utf-8')
    solutions = toolbox.kbest(pop,1)
    try:
        with open('sol-'+file_name,'w') as f:
            for sol in solutions:
                f.write('config=' + str(sol) + ', fitness=' + str(sol.fitness.values))
                print('config=' + str(sol) + ', fitness=' + str(sol.fitness.values))
        f.close()
    except IOError:
        print('Unable to store the cache')
    


#########################################################################################################################

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument(
          '--seed',
          type=int,
          default=1,
          help='Random seed.'
    )
    parser.add_argument(
          '--popsize',
          type=int,
          default=5,
          help='Random seed.'
    )
    parser.add_argument(
          '--offspring',
          type=int,
          default=2,
          help='Random seed.'
    )
    parser.add_argument(
          '--nev',
          type=int,
          default=10,
          help='Number of evaluations.'
    )
    parser.add_argument(
          '--cxpb',
          type=float,
          default=0.8,
          help='Crossover probability.'
    )
    parser.add_argument(
          '--mutpb',
          type=float,
          default=0.25,
          help='Mutation probability.'
    )
    parser.add_argument(
          '--stdf',
          type=float,
          default=0.01,
          help='Mutation adjustment factor.'
    )
    parser.add_argument(
          '--outf',
          type=str,
          default='out.csv',
          help='Output file (csv).'
    )

    FLAGS, unparsed = parser.parse_known_args()

    _load_cache(CACHE_FILE)
    main(seed=FLAGS.seed, pop_size=FLAGS.popsize, offspring_size=FLAGS.offspring, 
                NEV=FLAGS.nev, CXPB=FLAGS.cxpb, MUTPB=FLAGS.mutpb, 
                expt=DEFAULT_EXPERIMENT, file_name=FLAGS.outf, std_factor=FLAGS.stdf)
    _cache_to_csv(CACHE_FILE)

