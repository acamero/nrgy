from __future__ import print_function, division
import numpy as np
import random
import tensorflow as tf
import os
import json
from def_config import *
from data_wrapper import DataSet


DEF_INTRA_THREADS = 0 # Number of threads per individual Op (0 means that the system picks an appropriate number).
DEF_INTER_THREADS = 0 # Number of threads for blocking nodes (0 means that the system picks an appropriate number).


# Graph generation
def build_lstm_graph_with_config(config):
    tf.reset_default_graph()
    lstm_graph = tf.Graph()
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
                #loss = tf.losses.huber_loss(targets, prediction)
                optimizer = tf.train.AdamOptimizer(learning_rate)
                minimize = optimizer.minimize(loss, name="loss_mse_adam_minimize")
                tf.summary.scalar("loss_mse", loss)
            # Operators to use after restoring the model
            for op in [prediction, loss]:
                tf.add_to_collection('ops_to_restore', op)
    return lstm_graph


def _count_trainable_variables(graph, _print=False):
    total_parameters = 0
    with tf.Session(graph=graph) as sess:   
        for variable in tf.trainable_variables():
            # shape is an array of tf.Dimension
            shape = variable.get_shape()
            if _print:
                print(shape)
                print(len(shape))
            variable_parameters = 1
            for dim in shape:
                if _print:
                    print(dim)
                variable_parameters *= dim.value
            if _print:
                print(variable_parameters)
            total_parameters += variable_parameters
        if _print:
            print(total_parameters)
        ops = graph.get_operations()
    # with
    return total_parameters


def _compute_learning_rates(config, experiment):
    learning_rates_to_use = [
            config.init_learning_rate * (
                config.learning_rate_decay ** max(float(i + 1 - experiment.init_epoch), 0.0)
            ) for i in range(experiment.max_epoch)
    ]
    #print ("Middle learning rate:", learning_rates_to_use[len(learning_rates_to_use) // 2])
    return learning_rates_to_use


def train_lstm_graph(dataset, lstm_graph, config, experiment, predicts=False):
    final_prediction = []
    final_loss = None
    graph_name = "%s_lr%.2f_lr_decay%.3f_lstm%d_step%d_lays%d_input%d_batch%d_epoch%d" % (
        dataset.name,
        config.init_learning_rate, config.learning_rate_decay,
        config.lstm_size, config.num_steps, config.num_layers,
        config.input_size, experiment.batch_size, experiment.max_epoch)
    #print( "Graph Name:", graph_name)
    # Uncomment to print tensors
    # [print(n.name) for n in lstm_graph.as_graph_def().node]  
    learning_rates_to_use = _compute_learning_rates(config, experiment)
    with tf.Session(graph=lstm_graph, 
                    config=tf.ConfigProto(
                        inter_op_parallelism_threads=DEF_INTER_THREADS, 
                        intra_op_parallelism_threads=DEF_INTRA_THREADS) ) as sess:
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
        for epoch_step in range(experiment.max_epoch):
            current_lr = learning_rates_to_use[epoch_step]
            for batch_X, batch_y in dataset.generate_one_epoch(experiment.batch_size):
                train_data_feed = {
                    inputs: batch_X,
                    targets: batch_y,
                    learning_rate: current_lr
                }
                train_loss, _ = sess.run([loss, minimize], train_data_feed)
            # for
            if (1+epoch_step) % LOSS_REPORT == 0:
                test_loss, _pred, _summary = sess.run([loss, prediction, merged_summary], test_data_feed)
                assert len(_pred) == len(dataset.test_y)
                print( "Epoch %d [%f]:" % (epoch_step+1, current_lr), test_loss )
                if (1+epoch_step) % PREDICTIONS_REPORT == 0 and predicts:
                    print("Predictions:", [(
                        map(lambda x: round(x, 4), _pred[-j]),
                        map(lambda x: round(x, 4), dataset.test_y[-j])
                        ) for j in range(5)]
                    )
                writer.add_summary(_summary, global_step=epoch_step)
            # if
        # for
        #print("Final Results:")
        final_prediction, final_loss = sess.run([prediction, loss], test_data_feed)
        #print(final_prediction, final_loss)
        if not os.path.exists(MODEL_DIR):
            os.mkdir(MODEL_DIR)
        saver = tf.train.Saver()
        full_graph_path = os.path.join(MODEL_DIR, "%s_rnn_model_%s.ckpt" % (dataset.name, graph_name))
        saver.save(sess, full_graph_path, global_step=epoch_step)
        #saver.save(sess, full_graph_path)
    # with
    if predicts:
        if not os.path.exists(PREDICT_DIR):
            os.mkdir(PREDICT_DIR)
        with open(PREDICT_DIR + "/" + "final_predictions.{}.csv".format(graph_name), 'w') as fout:
            #fout.write(json.dumps(final_prediction.tolist()))
            fout.write("ground truth, prediction\n")
            for i in range(len(dataset.test_y)):
                fout.write(str(dataset.test_y[i])+","+str(final_prediction[i])+"\n")
    
    return final_loss, full_graph_path
# train_lstm_graph


def evaluate(dataset, config, experiment, predicts=False):
    lstm_graph = build_lstm_graph_with_config(config=config)
    loss, full_graph_path = train_lstm_graph(dataset, lstm_graph, config, experiment, predicts)
    no_vars = _count_trainable_variables(lstm_graph)
    return [loss, no_vars, full_graph_path]



