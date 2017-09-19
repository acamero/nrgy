import testdata as tdt
import mdrnn as md
from datetime import datetime
import numpy as np
import tensorflow as tf
import argparse
import os.path
import sys
import time

# DEFAULT VALUES
FLAGS = None

# System configuration
DEF_LOG_DIR = "logs"
DEF_RANDOM_SEED = 10
DEF_REPORT_CYCLE = 10
DEF_CHECKPOINT = 10
DEF_INTRA_THREADS = 0
DEF_INTER_THREADS = 0

# Data configuration
DEF_SYNTH_DIMENSIONS = 1 # Use to set the dims of the synth data
DEF_SYNTH_SIZE = 10000000 # Size of the synth feed
DEF_TEST_SET_PERC = 0.2 # x% of the data is going to be used for testing
DEF_BATCH_SIZE = 200
DEF_EPOCHS = 1

# MDRRN configuration
DEF_NUM_STEPS = 5 # number of truncated backprop steps

# Optimizer configuration
DEF_LEARNING_RATE = 0.001


#####################################################################################################################################


def save_checkpoint(saver, sess, step):
    checkpoint_file = os.path.join(FLAGS.log_dir, 'model.ckpt')
    saver.save(sess, checkpoint_file, global_step=step)

def get_placeholders(batch_size, num_steps, num_dimensions):
    input_placeholder = tf.placeholder(tf.float32, [batch_size, num_steps, num_dimensions])
    output_placeholder = tf.placeholder(tf.float32, [batch_size, num_steps])
    keep_p_placeholder = tf.placeholder(tf.float32)
    return input_placeholder, output_placeholder, keep_p_placeholder

def fill_feed_dict(sess, in_queue, out_queue, keep_p, in_pl, out_pl, keep_p_pl):
    in_feed, out_feed = sess.run([in_queue, out_queue])
    feed_dict = {
        in_pl: in_feed,
        out_pl: out_feed,
        keep_p_pl: keep_p
    }
    return feed_dict

def do_eval(sess, eval_correct, batch_size, in_queue, out_queue, keep_p, in_pl, out_pl, keep_p_pl):
    avg = 0  # Counts the number of correct predictions.
    size = 0
    # TODO improve or change
    for i in xrange(10):
        feed_dict, batch_size = fill_feed_dict(sess, in_queue, out_queue, keep_p, in_pl, out_pl, keep_p_pl)
        val = sess.run(eval_correct, feed_dict=feed_dict)
        avg = ((size * avg) + (val * batch_size)) / (size + batch_size)
        size += batch_size
    print('  Num examples: %d  Accuracy: %0.04f' % (size, avg))


#####################################################################################################################################

def run_training():    
    # Tell TensorFlow that the model will be built into the default Graph.
    with tf.Graph().as_default():
        tf.set_random_seed(FLAGS.random_seed)
        np.random.seed(FLAGS.random_seed)
        # TODO divide data FLAGS.test_set_perc
        if FLAGS.energy_load:
            data = tdt.get_load(sel)
            # TODO determine the number of dimensions
            num_dimensions = 1
        else:
            data = tdt.get_synth(FLAGS.epochs, FLAGS.num_steps, FLAGS.batch_size, FLAGS.synth_size, FLAGS.synth_dimensions)
            num_dimensions = FLAGS.synth_dimensions
        # TODO enqueue data
        # TODO Generate placeholders for the images and labels.
        input_placeholder, output_placeholder, keep_p_placeholder = get_placeholders(None, FLAGS.num_steps, num_dimensions)
        # TODO Build a Graph that computes predictions from the inference model.
        mdrnn = md.inference(input_placeholder, keep_p_placeholder, FLAGS.batch_size, FLAGS.num_steps)    
        # TODO Add to the Graph the Ops for loss calculation.
        loss = md.loss(mdrnn, output_placeholder)
        # TODO Add to the Graph the Ops that calculate and apply gradients.
        train_op = md.training(loss, FLAGS.learning_rate)
        # TODO Add the Op to compare the prediction to the labels during evaluation.
        eval_correct = md.evaluation(mdrnn, output_placeholder)
        # Build the summary Tensor based on the TF collection of Summaries.
        summary = tf.summary.merge_all()
        # Add the variable initializer Op.
        init = tf.global_variables_initializer()
        # TODO Create a saver for writing training checkpoints.
        saver = tf.train.Saver()
        # Create a session for running Ops on the Graph.
        with tf.Session(
                config=tf.ConfigProto(
                    inter_op_parallelism_threads=FLAGS.inter_threads, 
                    intra_op_parallelism_threads=FLAGS.intra_threads)) as sess: 
            # Instantiate a SummaryWriter to output summaries and the Graph.
            summary_writer = tf.summary.FileWriter(FLAGS.log_dir, sess.graph)
            # And then after everything is built:
            # Run the Op to initialize the variables.
            sess.run(init)
            coord = tf.train.Coordinator()
            threads = tf.train.start_queue_runners(sess=sess, coord=coord)
            # TODO Start the training loop. (iterate over epochs)
            try:
                step = 0
                while not coord.should_stop():
                    coord.request_stop()
                    start_time = time.time()
                    # TODO feed dict
                    #feed_dict,_ = fill_feed_dict(
                    # TODO Run one step of the model.  The return values are the activations
                    # from the `train_op` (which is discarded) and the `loss` Op.  To
                    # inspect the values of your Ops or variables, you may include them    
                    # in the list passed to sess.run() and the value tensors will be
                    # returned in the tuple from the call.
                    #_, loss_value = sess.run([train_op, loss], feed_dict=feed_dict)    
                    duration = time.time() - start_time
                    # Write the summaries and print an overview fairly often.
                    if step % FLAGS.report_cycle == 0:
                        # TODO Print status to stdout.
                        loss_value = 0
                        print('Step %d: loss = %.2f (%.3f sec)' % (step, loss_value, duration))    
                        # TODO Update the events file.    
                        #summary_str = sess.run(summary, feed_dict=feed_dict)
                        #summary_writer.add_summary(summary_str, step)
                        #summary_writer.flush()  
                    # Save a checkpoint and evaluate the model periodically.
                    if (step + 1) % FLAGS.checkpoint == 0:
                        save_checkpoint(sess, step)
                        # TODO Evaluate against the training set.
                        print('Training Data Eval:')    
                        #do_eval(sess,
                        # TODO Evaluate against the test set.                    
                        print('Test Data Eval:')
                        #do_eval(sess,
                    # if
                    step += 1
                # while
            except Exception, e:
                print e
            finally:
                # TODO Save the last version of the model
                #save_checkpoint(saver, sess, step)
                coord.request_stop()
                coord.join(threads)
            sess.close()
        # with
    # 
# def

#####################################################################################################################################

def main(_):
    if tf.gfile.Exists(FLAGS.log_dir):
        tf.gfile.DeleteRecursively(FLAGS.log_dir)
    tf.gfile.MakeDirs(FLAGS.log_dir)
    run_training()


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument(
          '--execute',
          default=False,
          help='If true, execute the training.',
          action='store_true'
    )
    # System configuration
    parser.add_argument(
          '--log_dir',
          type=str,
          default=DEF_LOG_DIR,
          help='Directory to put the log data.'
    )
    parser.add_argument(
          '--random_seed',
          type=int,
          default=DEF_RANDOM_SEED,
          help='Random seed.'
    )
    parser.add_argument(
          '--report_cycle',
          type=int,
          default=DEF_REPORT_CYCLE,
          help='Number of steps to run trainer.'
    )
    parser.add_argument(
          '--checkpoint',
          type=int,
          default=DEF_CHECKPOINT,
          help='Number of steps to run trainer.'
    )
    parser.add_argument(
          '--inter_threads',
          type=int,
          default=DEF_INTER_THREADS,
          help='Number of threads for blocking nodes (0 means that the system picks an appropriate number).'
    )
    parser.add_argument(
          '--intra_threads',
          type=int,
          default=DEF_INTRA_THREADS,
          help='Number of threads per individual Op (0 means that the system picks an appropriate number).'
    )
    # Data configuration
    parser.add_argument(
          '--energy_load',
          default=False,
          help='If true, use energy load.',
          action='store_true'
    )
    parser.add_argument(
          '--synth_dimensions',
          type=int,
          default=DEF_SYNTH_DIMENSIONS,
          help='Number of dimensions for synth data.'
    )
    parser.add_argument(
          '--synth_size',
          type=int,
          default=DEF_SYNTH_SIZE,
          help='Synth data feed size.'
    )
    parser.add_argument(
          '--test_set_perc',
          type=float,
          default=DEF_TEST_SET_PERC,
          help='Relative size of the test set.'
    )
    parser.add_argument(
          '--batch_size',
          type=int,
          default=DEF_BATCH_SIZE,
          help='Batch size.  Must divide evenly into the dataset sizes.'
    )
    parser.add_argument(
          '--epochs',
          type=int,
          default=DEF_EPOCHS,
          help='Train epochs.'
    )
    # MDRRN configuration
    parser.add_argument(
          '--num_steps',
          type=int,
          default=DEF_NUM_STEPS,
          help='Number of steps of the MDRNN.'
    )
    # Optimizer configuration
    parser.add_argument(
          '--learning_rate',
          type=float,
          default=DEF_LEARNING_RATE,
          help='Initial learning rate.'
    )
 
    FLAGS, unparsed = parser.parse_known_args()
    tf.app.run(main=main, argv=[sys.argv[0]] + unparsed)
#


