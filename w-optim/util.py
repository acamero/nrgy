import numpy as np
import os
import pandas as pd
import glob
import json
from abc import ABC, abstractmethod
from dateutil.parser import parse

############################################################################################################
def mse_loss(y_predict, y):
    return np.mean(np.square(y_predict - y)) 

def mae_loss(y_predict, y):
    return np.mean(np.abs(y_predict - y)) 


############################################################################################################
class DataReader(ABC):
    @abstractmethod
    def load_data(self, data_path):
        raise NotImplemented()

class ParkingDFDataReader(DataReader):
    """
    """
    def load_data(self, data_path, inner=False):
        dfs = {}
        train_file = 'training_norm_outer_df.csv'
        test_file = 'testing_norm_outer_df.csv'
        if inner:
            train_file = 'training_norm_inner_df.csv'
            test_file = 'testing_norm_inner_df.csv'
        temp_df = pd.read_csv(data_path + train_file, sep = ',')
        temp_df = temp_df.set_index(temp_df['Datetime'].values)
        temp_df.drop(['Datetime'], axis=1, inplace=True)        
        dfs['train'] = temp_df
        temp_df = pd.read_csv(data_path + test_file, sep = ',')
        temp_df = temp_df.set_index(temp_df['Datetime'].values)
        temp_df.drop(['Datetime'], axis=1, inplace=True)
        dfs['test'] = temp_df
        return dfs


############################################################################################################     
class Config(object):

    def __init__(self):
        # Default params
        self.config_name = 'default'
        self.data_folder = '../data/'
        self.mode_folder = 'models/'
        self.results_folder = 'results/'
        self.optimizer_class = None
        self.data_reader_class = None
        self.x_features = []
        self.y_features = []        
        self.max_look_back = 100
        self.max_neurons = 16
        self.max_layers = 16
    
    def __str__(self):
        return str(self.__dict__)
    
    def is_equal(self, to):
        if str(to)==str(self):
            return True
        return False

    def get(self, attr):
        return getattr(self, attr)

    def set(self, attr, value):
        setattr(self, attr, value)
    
    def load_from_file(self, filename):
        json_config = {}
        try:
            with open(filename, 'r') as f:
                f_str = f.read()
                json_config = json.loads(f_str)
            f.close()
        except IOError:
            print('Unable to load the configuration file')
        # Update the configuration using the data in the file
        for key in json_config:
            if key == 'optimizer_class' and json_config[key] != '':
                if json_config[key].count('.') > 0:
                    module_name = json_config[key][0:json_config[key].rfind('.')]
                    class_name = json_config[key][json_config[key].rfind('.')+1:]
                    self.optimizer_class = getattr( __import__(module_name), class_name )
                else:
                    self.optimizer_class = locals()[json_config[key]]
            elif key == 'data_reader_class' and json_config[key] != '':
                if json_config[key].count('.') > 0:
                    module_name = json_config[key][0:json_config[key].rfind('.')]
                    class_name = json_config[key][json_config[key].rfind('.')+1:]
                    self.data_reader_class = getattr( __import__(module_name), class_name )
                else:
                    self.data_reader_class = locals()[json_config[key]]
            else:
                setattr(self, key, json_config[key])

