import numpy as np
from data_wrapper import DataSet


# Data generation
def generate_data(config, experiment):
    # TODO improve by adding/changing the sequence generation function  
    #x = np.array(np.sin(range(0, experiment.seq_length)))
    _range = np.linspace(experiment.seq_start, experiment.seq_end, experiment.seq_length, endpoint=False)
    x = np.array(experiment.data_function(_range))  
    return DataSet(experiment.data_name, x, config.input_size, config.num_steps, experiment.test_ratio)


