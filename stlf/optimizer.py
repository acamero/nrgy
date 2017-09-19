from __future__ import division
from util.def_config import *
from util.data_generation import generate_data
from util.simple_rnn import evaluate
from nao.pso import PSO
import numpy as np
import tensorflow as tf

MAX_ITER = 2
_CACHE = {}

def upsert_cache(config, fitness):
  if fitness:
    _CACHE[str(config)] = fitness
    return _CACHE[str(config)]
  elif str(config) in _CACHE:
    return _CACHE[str(config)]
  return None


#class RNNConfig():
#  input_size=5
#  num_steps=5
#  lstm_size=32
#  num_layers=1
#  keep_prob=0.8
#  init_learning_rate = 0.02
#  learning_rate_decay = 0.995

# the function we are attempting to optimize (minimize)
def evaluate_configuration(encoded_config, experiment):
  # decode config
  config = Config()
  config.lstm_size = encoded_config[0]
  config.num_layers = encoded_config[1]
  config.keep_prob = float(encoded_config[2]/100)
  loss = upsert_cache(config, None)
  print("Loss from cache:",loss)
  if not loss:
    dataset = generate_data(config, experiment)
    loss = evaluate(dataset, config, experiment, predicts=False)
    upsert_cache(config, loss)
  print("Configuration", str(config), "Fitness", loss)  
  return loss

def configure_pso():
  # lstm_size, num_layers, keep_prob
  initial=[32,1,80]
  bounds=[(1,128),(1,10),(1,100)]
  pso=PSO(initial,bounds,num_particles=15)
  return pso

def main(config=DEFAULT_CONFIG, experiment=DEFAULT_EXPERIMENT, max_iter=MAX_ITER, seed=1):
  np.random.seed(seed)
  tf.set_random_seed(seed)
  # TODO select algorithm
  algorithm = configure_pso()
  algorithm.optimize(evaluate_configuration, max_iter, experiment)

if __name__ == '__main__':
  main()
