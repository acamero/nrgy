from __future__ import division
import numpy as np
import random

class DataSet(object):
  def __init__(self, name, seq, input_size, num_steps, test_ratio):
    self.name = name
    self.input_size = input_size
    self.num_steps = num_steps
    self.test_ratio = test_ratio
    self._prepare_data(seq)

  def _prepare_data(self, seq):
    #seq = [np.array(seq[i * self.input_size: (i + 1) * self.input_size])
    #           for i in range(len(seq) // self.input_size)]
    # split into groups of num_steps
    X = np.array([seq[i: i + self.num_steps] for i in range(len(seq) - self.num_steps)])
    y = np.array([seq[i + self.num_steps] for i in range(len(seq) - self.num_steps)])
    train_size = int(len(X) * (1.0 - self.test_ratio))
    self.train_X, self.test_X = X[:train_size], X[train_size:]
    self.train_y, self.test_y = y[:train_size], y[train_size:]

  def generate_one_epoch(self, batch_size):
    num_batches = int(len(self.train_X)) // batch_size
    if batch_size * num_batches < len(self.train_X):
      num_batches += 1
    batch_indices = range(num_batches)
    random.shuffle(batch_indices)
    for j in batch_indices:
      batch_X = self.train_X[j * batch_size: (j + 1) * batch_size]
      batch_y = self.train_y[j * batch_size: (j + 1) * batch_size]
      assert set(map(len, batch_X)) == {self.num_steps}
      yield batch_X, batch_y

