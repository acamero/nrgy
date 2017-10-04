import numpy as np
from data_wrapper import DataSet


# Data generation
def generate_data(config, experiment):
    # TODO improve by adding/changing the sequence generation function  
    #x = np.array(np.sin(range(0, experiment.seq_length)))
    if experiment.seq_mirror:
        _range = range(-experiment.seq_length/2,experiment.seq_length/2)
    else:
        _range = range(0, experiment.seq_length)
    x = np.array(experiment.data_function(_range))  
    return DataSet(experiment.data_name, x, config.input_size, config.num_steps, experiment.test_ratio)


