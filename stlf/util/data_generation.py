import numpy as np
from data_wrapper import DataSet


# Data generation
def generate_data(config, experiment):
    _range = np.linspace(experiment.seq_start, experiment.seq_end, experiment.seq_length, endpoint=False)
    if not experiment.additional_data:
        x = np.array(experiment.data_function(_range))  
    else:
        x = np.array(experiment.data_function(_range, config, experiment))
    return DataSet(experiment.data_name, x, config.input_size, config.num_steps, experiment.test_ratio)


