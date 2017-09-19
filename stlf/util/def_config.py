import numpy as np

# RNN Architecture
class Config(object):
  def __init__(self):
    self.input_size=5
    self.num_steps=5
    self.lstm_size=32
    self.num_layers=1
    self.keep_prob=0.8
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
    self.init_epoch = 1
    self.max_epoch = 5
    self.batch_size = 100
    self.seq_length = 1000000
    self.test_ratio = 0.1
  def __str__(self):
    return str(self.__dict__)
  def is_equal(self, to):
    if str(to)==str(self):
      return True
    return False

# Params
DEFAULT_CONFIG = Config()
DEFAULT_EXPERIMENT = Experiment()

LOG_DIR = "_logs"
MODEL_DIR = "_models"
PREDICT_DIR = "_predicts"

LOSS_REPORT = 5
PREDICTIONS_REPORT = 10

