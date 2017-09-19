from __future__ import print_function, division
import numpy as np
import random
import tensorflow as tf
import os
import json


# Architecture
class RNNConfig():
  input_size=5
  num_steps=10
  lstm_size=32
  num_layers=1
  keep_prob=0.8
  batch_size = 100
  init_learning_rate = 0.02
  learning_rate_decay = 0.995
  init_epoch = 1
  max_epoch = 10

DEFAULT_CONFIG = RNNConfig()
LOG_DIR = "logs"
MODEL_DIR = "models"
PREDICT_DIR = "predicts"
SEQ_LENGTH = 1000000


class DataSet(object):
  def __init__(self, name, seq, input_size, num_steps, test_ratio):
    self.name = name
    self.input_size = input_size
    self.num_steps = num_steps
    self.test_ratio = test_ratio
    self._prepare_data(seq)

  def _prepare_data(self, seq):
    seq = [np.array(seq[i * self.input_size: (i + 1) * self.input_size])
               for i in range(len(seq) // self.input_size)]
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


# Data generation
def generate_data(config, seq_length=SEQ_LENGTH, test_size=0.1):
  if config is None:
    config = DEFAULT_CONFIG
  # TODO improve by adding/changing the sequence generation function
  x = np.array(np.sin(range(0, seq_length)))  
  return DataSet('sin', x, config.input_size, config.num_steps, test_size)


# Graph generation
def build_lstm_graph_with_config(config):
  tf.reset_default_graph()
  lstm_graph = tf.Graph()
  if config is None:
    config = DEFAULT_CONFIG

  with lstm_graph.as_default():
    learning_rate = tf.placeholder(tf.float32, None, name="learning_rate")

    # Number of examples, number of input, dimension of each input
    inputs = tf.placeholder(tf.float32, [None, config.num_steps, config.input_size], name="inputs")
    targets = tf.placeholder(tf.float32, [None, config.input_size], name="targets")

    def _create_one_cell():
      lstm_cell = tf.contrib.rnn.LSTMCell(config.lstm_size, state_is_tuple=True)
      if config.keep_prob < 1.0:
        lstm_cell = tf.contrib.rnn.DropoutWrapper(lstm_cell, output_keep_prob=config.keep_prob)
      return lstm_cell

    cell = tf.contrib.rnn.MultiRNNCell(
                  [_create_one_cell() for _ in range(config.num_layers)],
	          state_is_tuple=True
    ) if config.num_layers > 1 else _create_one_cell()

    val, _ = tf.nn.dynamic_rnn(cell, inputs, dtype=tf.float32, scope="lilian_rnn")

    # Before transpose, val.get_shape() = (batch_size, num_steps, lstm_size)
    # After transpose, val.get_shape() = (num_steps, batch_size, lstm_size)
    val = tf.transpose(val, [1, 0, 2])

    with tf.name_scope("output_layer"):
      # last.get_shape() = (batch_size, lstm_size)
      last = tf.gather(val, int(val.get_shape()[0]) - 1, name="last_lstm_output")

      weight = tf.Variable(tf.truncated_normal([config.lstm_size, config.input_size]), name="lilian_weights")
      bias = tf.Variable(tf.constant(0.1, shape=[config.input_size]), name="lilian_biases")
      prediction = tf.matmul(last, weight) + bias

      tf.summary.histogram("last_lstm_output", last)
      tf.summary.histogram("weights", weight)
      tf.summary.histogram("biases", bias)

      with tf.name_scope("train"):
        # loss = -tf.reduce_sum(targets * tf.log(tf.clip_by_value(prediction, 1e-10, 1.0)))
        loss = tf.reduce_mean(tf.square(prediction - targets), name="loss_mse")
        optimizer = tf.train.AdamOptimizer(learning_rate)
        minimize = optimizer.minimize(loss, name="loss_mse_adam_minimize")
        tf.summary.scalar("loss_mse", loss)

      # Operators to use after restoring the model
      for op in [prediction, loss]:
        tf.add_to_collection('ops_to_restore', op)

  return lstm_graph


def _compute_learning_rates(config):
  if config is None:
    config = DEFAULT_CONFIG
  learning_rates_to_use = [
        config.init_learning_rate * (
            config.learning_rate_decay ** max(float(i + 1 - config.init_epoch), 0.0)
        ) for i in range(config.max_epoch)
  ]
  print ("Middle learning rate:", learning_rates_to_use[len(learning_rates_to_use) // 2])
  return learning_rates_to_use


def train_lstm_graph(dataset, lstm_graph, config, predicts=False):
  if config is None:
    config = DEFAULT_CONFIG
  final_prediction = []
  final_loss = None
  graph_name = "%s_lr%.2f_lr_decay%.3f_lstm%d_step%d_input%d_batch%d_epoch%d" % (
        dataset.name,
        config.init_learning_rate, config.learning_rate_decay,
        config.lstm_size, config.num_steps,
        config.input_size, config.batch_size, config.max_epoch)
  print( "Graph Name:", graph_name)
  # Uncomment to print tensors
  # [print(n.name) for n in lstm_graph.as_graph_def().node]  
  learning_rates_to_use = _compute_learning_rates(config)
  with tf.Session(graph=lstm_graph) as sess:
    merged_summary = tf.summary.merge_all()
    writer = tf.summary.FileWriter(LOG_DIR + '/' + graph_name, sess.graph)
    writer.add_graph(sess.graph)
    graph = tf.get_default_graph()
    tf.global_variables_initializer().run()
    inputs = graph.get_tensor_by_name('inputs:0')
    targets = graph.get_tensor_by_name('targets:0')
    learning_rate = graph.get_tensor_by_name('learning_rate:0')
    test_data_feed = {
            inputs: dataset.test_X,
            targets: dataset.test_y,
            learning_rate: 0.0
    }
    loss = graph.get_tensor_by_name('output_layer/train/loss_mse:0')
    minimize = graph.get_operation_by_name('output_layer/train/loss_mse_adam_minimize')
    prediction = graph.get_tensor_by_name('output_layer/add:0')
    for epoch_step in range(config.max_epoch):
      current_lr = learning_rates_to_use[epoch_step]
      for batch_X, batch_y in dataset.generate_one_epoch(config.batch_size):
        train_data_feed = {
                    inputs: batch_X,
                    targets: batch_y,
                    learning_rate: current_lr
        }
        train_loss, _ = sess.run([loss, minimize], train_data_feed)
      # for
      if epoch_step % 5 == 0:
        test_loss, _pred, _summary = sess.run([loss, prediction, merged_summary], test_data_feed)
        assert len(_pred) == len(dataset.test_y)
        print( "Epoch %d [%f]:" % (epoch_step, current_lr), test_loss )
        if epoch_step % 10 == 0:
          print("Predictions:", [(
                        map(lambda x: round(x, 4), _pred[-j]),
                        map(lambda x: round(x, 4), dataset.test_y[-j])
               ) for j in range(5)]
          )
      # if
      writer.add_summary(_summary, global_step=epoch_step)
    # for
    print("Final Results:")
    final_prediction, final_loss = sess.run([prediction, loss], test_data_feed)
    print(final_prediction, final_loss)
    #graph_saver_dir = os.path.join(MODEL_DIR, graph_name)
    if not os.path.exists(MODEL_DIR):
      os.mkdir(MODEL_DIR)
    saver = tf.train.Saver()
    saver.save(sess, os.path.join(MODEL_DIR, "%s_rnn_model_%s.ckpt" % (dataset.name, graph_name)), global_step=epoch_step)
  # with
  if predicts:
    if not os.path.exists(PREDICT_DIR):
      os.mkdir(PREDICT_DIR)
    with open(PREDICT_DIR + "/" + "final_predictions.{}.json".format(graph_name), 'w') as fout:
      fout.write(json.dumps(final_prediction.tolist()))
  return final_loss
# train_lstm_graph


def main(config=DEFAULT_CONFIG):
  lstm_graph = build_lstm_graph_with_config(config=config)
  dataset = generate_data(config)
  loss = train_lstm_graph(dataset, lstm_graph, config=config)
  print("Fitness",loss)


if __name__ == '__main__':
  main()
