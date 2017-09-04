import tensorflow as tf


def inference(input_pl, keep_p_pl, batch_size, num_steps):
    # TODO redo everything!
    linear_units = 256
    num_classes = num_steps
    in_size = reduce(lambda x,y: (x if x else 1) * (y if y else 1), input_pl.get_shape().as_list()[1:])
    flatten = tf.reshape(input_pl, [-1, in_size])
    with tf.name_scope('linear'):
        weights = tf.Variable(
            tf.truncated_normal([in_size, linear_units], stddev=0.1),
            name='weights')  
        biases = tf.Variable(
            tf.constant(0.1, shape=[linear_units]),
            name='biases')
        linear = tf.nn.relu(tf.matmul(flatten, weights) + biases)
    # Output
    with tf.name_scope('output'):
        dropout = tf.nn.dropout(linear, keep_p_pl)
        weights = tf.Variable(
            tf.truncated_normal([linear_units, num_classes], stddev=0.1),
            name='weights')
        biases = tf.Variable(
            tf.constant(0.1, shape=[num_classes]),
            name='biases')
        output = tf.matmul(dropout, weights) + biases
    return output

def loss(predicted_value, value):
    # TODO calculate loss, remember that we are predicting a real value, not a class
    return tf.reduce_mean( tf.nn.softmax_cross_entropy_with_logits(labels=value, logits=predicted_value), name='xentropy_mean')

def training(loss, learning_rate):
    # Add a scalar summary for the snapshot loss.
    tf.summary.scalar('loss', loss)
    # Create the gradient descent optimizer with the given learning rate.
    optimizer = tf.train.GradientDescentOptimizer(learning_rate)
    # Create a variable to track the global step.
    global_step = tf.Variable(0, name='global_step', trainable=False)
    # Use the optimizer to apply the gradients that minimize the loss
    # (and also increment the global step counter) as a single training step.
    train_op = optimizer.minimize(loss, global_step=global_step)
    return train_op

def evaluation(predicted_value, value):
    # TODO update! We are not classifiying, but predicting a real continuous value
    return tf.reduce_mean(tf.cast(tf.equal(tf.argmax(predicted_value,1),tf.argmax(value,1)),tf.float32))
