import numpy as np
import json

# RNN Architecture
class Config(object):
  def __init__(self):
    self.input_size=1 # number of dimensions
    self.num_steps=5 # how many times we look back
    self.lstm_size=32 # number of cells per layer
    self.num_layers=1 # number of hidden layers
    self.keep_prob=0.8 # drop out probability
    self.init_learning_rate = 0.02
    self.learning_rate_decay = 0.995
  def __str__(self):
    return str(self.__dict__)
  def is_equal(self, to):
    if str(to)==str(self):
      return True
    return False

#
class Experiment(object):
    def __init__(self):
        self.data_name = 'sin'
        self.data_function = np.sin
        self.dimensions = 1
        self.additional_data = 0
        self.init_epoch = 1
        self.max_epoch = 100
        self.batch_size = 100
        self.seq_start = 0
        self.seq_end = 10000
        self.seq_length = 10000
        self.test_ratio = 0.2
    #
    def __str__(self):
        return str(self.__dict__)
    #
    def is_equal(self, to):
        if str(to)==str(self):
            return True
        return False
    #
    def load_from_file(self, file_path):
        json_config = {}
        try:
            with open(file_path, 'r') as f:
                f_str = f.read()
                json_config = json.loads(f_str)
            f.close()
        except IOError:
            print('Unable to load the experiment file')
        #
        for key in json_config:
            if key == 'data_function' and json_config[key] != '':
                if json_config[key].count('.') > 0:
                    module_name = json_config[key][0:json_config[key].rfind('.')]
                    func_name = json_config[key][json_config[key].rfind('.')+1:]
                    self.data_function = getattr( __import__(module_name), func_name )
                else:
                    self.data_function = locals()[json_config[key]]
            else:
                setattr(self, key, json_config[key])
    #
#



# Params
DEFAULT_CONFIG = Config()
DEFAULT_EXPERIMENT = Experiment()

LOG_DIR = "_logs"
MODEL_DIR = "_models"
PREDICT_DIR = "_predicts"

LOSS_REPORT = 5
PREDICTIONS_REPORT = 200

