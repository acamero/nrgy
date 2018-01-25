import tensorflow as tf
from keras.models import load_model
import util as ut
import argparse
import numpy as np
import pandas as pd

#########################################################################################################################
def prepare_data(df, x_features, y_features, look_back):
    len_data = df.shape[0]        
    x = np.array( [df[x_features].values[i:i+look_back] 
            for i in range(len_data - look_back)] ).reshape(-1,look_back, len(x_features))
    y = df[y_features].values[look_back:,:]
    return x,y

def predict(model_file, df, x_features, y_features, look_back):
    model = load_model(model_file)
    X_test, y_test = prepare_data(df, x_features, y_features, look_back)
    pred_lstm = model.predict(X_test)
    mse_loss_lstm = ut.mse_loss(pred_lstm, y_test)
    mae_loss_lstm = ut.mae_loss(pred_lstm, y_test)
    print('Mean square error on test set: ', mse_loss_lstm)
    print('Mean absolute error on the test set: ', mae_loss_lstm)
    pred_df = pd.DataFrame( pred_lstm )
    pred_df.columns = config.y_features
    #pred_df['Datetime'] = df.index.values[look_back:]
    pred_df = pred_df.set_index(df.index.values[look_back:])
    #        temp_df.drop(['Date','Timestamp', 'timestamp'], axis=1, inplace=True)
    return pred_df, mse_loss_lstm, mae_loss_lstm

def decode_solution(encoded_solution, layer_in, layer_out):
    # 'drop-out' in [0,99]
    # 'look back' in [1, config.max_look_back]
    # 'rnn_arch' list (layer_in, layer_1, ..., layer_n, layer_out)
    # layer_in = len(config.x_features)
    # (layer_1, ...,layer_n), layer_i in [1, config.max_neurons], n in [1, config.max_layers]
    # layer_out = len(config.y_features)        
    decoded = {}
    decoded['drop_out'] = float(encoded_solution[0]/100)
    decoded['look_back'] = encoded_solution[1]
    decoded['rnn_arch'] = [layer_in] + encoded_solution[2:] + [layer_out]
    return decoded


#########################################################################################################################

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument(
          '--config',
          type=str,
          default='config.json',
          help='Experiment configuration file path (json format).'
    )
        
    FLAGS, unparsed = parser.parse_known_args()
    config = ut.Config()
    config.load_from_file(FLAGS.config)
    reader =config.data_reader_class()
    data_dict = reader.load_data( config.data_folder )
    layer_in = len(config.x_features)
    layer_out = len(config.y_features)
    decoded = decode_solution( config.solution, layer_in, layer_out )
    model_name = '-'.join(map(str, decoded['rnn_arch'])) + '.'
    model_name = model_name + str(decoded['look_back']) + '.' 
    model_name = model_name + str(decoded['drop_out']) 
    model_file = config.models_folder + model_name + '.hdf5'
    pred_df, mse_loss_lstm, mae_loss_lstm = predict( model_file, data_dict['test'], 
            config.x_features, config.y_features, decoded['look_back'])
    pred_df.to_csv(config.results_folder + model_name + '.csv' )

