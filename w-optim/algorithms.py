import rnn as nn
import util as ut
from optimizer import BaseOptimizer
import numpy as np
import pandas as pd
from abc import ABC, abstractmethod
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



#########################################################################################################################
class EBase(BaseOptimizer):

    @abstractmethod
    def _mate(self, ind1, ind2):
        raise NotImplemented()

    @abstractmethod
    def _mutate(self, ind):
        raise NotImplemented()

    @abstractmethod
    def _select(self, individuals, k):
        raise NotImplemented()  

    @abstractmethod
    def _replace(self, pop, offspring):
        raise NotImplemented() 

    @abstractmethod
    def _auto_adjust(self, logbook):
        raise NotImplemented() 

    def _validate_config(self, config):
        """
        pop_size: population size
        cx_prob: crossover probability
        mut_prob: mutation probability
        max_evals: maximum number of evaluations
        offspring_size: size of the offspring
        targets: list of targets (min -1.0 or max 1.0), e.g. [-1.0, -1.0]
        metrics: list of metrics ('mean_mse', 'mean_mae', 'mse_dtl', 'mae_dtl', 
            'trainable_vars', 'train_time_dtl', 'mean_train_time'), e.g. ['mean_mse', 'trainable_vars']
        """
        if config.pop_size is None or config.pop_size < 1:
            return False
        if config.max_evals is None or config.max_evals < 1:
            return False
        if config.offspring_size is None or config.offspring_size < 1:
            return False
        if config.targets is None or len(config.targets) < 1:
            return False
        if config.metrics is None or len(config.metrics) < 1:
            return False
        return True

    def _evaluate_individual(self, individual):
        metrics_dict = self._evaluate_solution(individual)
        return [metrics_dict[x] for x in self.config.metrics]

    def _decode_solution(self, encoded_solution):
        raise 'Not implemented yet'

    def _init_individual(self, clazz):
        # range [min,max)
        raise 'Not implemented yet'

    def _validate_individual(self, individual):
        raise 'Not implemented yet'

    def _run_algorithm(self, stats, hall_of_fame):
        # First, we initialize the framework
        creator.create("FitnessMulti", base.Fitness, weights=self.config.targets)
        creator.create("Individual", list, fitness=creator.FitnessMulti)
        toolbox = base.Toolbox()
        toolbox.register("individual", self._init_individual, clazz=creator.Individual)
        toolbox.register("population", tools.initRepeat, list, toolbox.individual)
        toolbox.register("evaluate", self._evaluate_individual)
        toolbox.register("mate", self._mate)
        toolbox.register("mutate", self._mutate)
        toolbox.register("select", self._select)
        toolbox.register("replace", self._replace)
        # Initialize the logger
        logbook = tools.Logbook()
        # Initialize population
        pop = toolbox.population(n=self.config.pop_size)
        # Evaluate the entire population
        fitnesses = list(map(toolbox.evaluate, pop))
        for ind, fit in zip(pop, fitnesses):
            ind.fitness.values = fit
        if hall_of_fame is not None:
            hall_of_fame.update(pop)
        # Gather the stats
        record = stats.compile(pop)
        print(record)
        evals = self.config.pop_size
        logbook.record(evaluations=evals, gen=0, **record)
        g = 1
        # Begin the evolution
        while evals < self.config.max_evals:
            print("-- Generation %i --" % g)
            # Select the next generation individuals
            if self.config.offspring_size > 1:
                offspring = toolbox.select(pop, self.config.offspring_size)
            else:
                offspring = toolbox.select(pop, 2)
            # Clone the selected individuals
            offspring = list(map(toolbox.clone, offspring))
            # Apply crossover and mutation on the offspring
            for child1, child2 in zip(offspring[::2], offspring[1::2]):
                toolbox.mate(child1, child2)
            if self.config.offspring_size == 1:  
                offspring = [offspring[0]]
            for mutant in offspring:
                toolbox.mutate(mutant)
            # Evaluate the individuals with an invalid fitness
            invalid_ind = [ind for ind in offspring if not ind.fitness.valid]
            fitnesses = map(toolbox.evaluate, invalid_ind)
            for ind, fit in zip(invalid_ind, fitnesses):
                ind.fitness.values = fit
            # Replacement
            pop[:] = toolbox.replace(pop, offspring)
            # Gather the stats
            record = stats.compile(pop)
            print(record)
            evals = evals + self.config.offspring_size
            if hall_of_fame is not None:
                hall_of_fame.update(pop)
            logbook.record(evaluations=evals, gen=g, **record)
            # The algorithm might adjust the parameters
            self._auto_adjust(logbook)
            g += 1
        return pop, logbook, hall_of_fame

         

#########################################################################################################################



