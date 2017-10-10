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


#########################################################################################################################

# Convert an individual into a NN configuration
def get_config(lstm_size, num_layers, keep_prob, num_steps, experiment):    
    config = Config()
    config.lstm_size = lstm_size
    config.num_layers = num_layers
    config.keep_prob = float(keep_prob/100)
    config.num_steps = num_steps
    config.input_size = experiment.dimensions
    return config


# Evaluate the NN represented by the individual
def train_test_config(config, experiment):
    dataset = generate_data(config, experiment)
    loss, no_vars, full_graph_path = evaluate(dataset, config, experiment, predicts=True)
    print("Loss", loss, "Number of variables", no_vars)


#########################################################################################################################

def main(seed, lstm_size, num_layers, keep_prob, num_steps, experiment):
    print("seed", seed, "experiment", str(experiment), 
            "lstm_size", lstm_size, "num_layers", num_layers, "keep_prob", keep_prob, "num_steps", num_steps)
    np.random.seed(seed)
    tf.set_random_seed(seed)
    random.seed(seed)
    config = get_config(lstm_size, num_layers, keep_prob, num_steps, experiment)
    train_test_config(config, experiment)
    


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
          '--lstm_size',
          type=int,
          default=1,
          help='LSTM cells per layer.'
    )
    parser.add_argument(
          '--num_layers',
          type=int,
          default=1,
          help='Number of hidden layers.'
    )
    parser.add_argument(
          '--keep',
          type=int,
          default=100,
          help='Keep probability [1..100].'
    )
    parser.add_argument(
          '--num_steps',
          type=int,
          default=1,
          help='Number of steps.'
    )
    parser.add_argument(
          '--experiment',
          type=str,
          default='',
          help='Experiment configuration file path (json format).'
    )

    FLAGS, unparsed = parser.parse_known_args()

    experiment = DEFAULT_EXPERIMENT
    if FLAGS.experiment != '':
        experiment.load_from_file(FLAGS.experiment)

    main(seed=FLAGS.seed, lstm_size= FLAGS.lstm_size, num_layers=FLAGS.num_layers, 
                keep_prob=FLAGS.keep, num_steps=FLAGS.num_steps,
                experiment=experiment)

