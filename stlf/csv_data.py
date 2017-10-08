import pandas as pd
import json

_DATA_OBJ = None

def _get_data_obj(config, experiment):
    global _DATA_OBJ
    if not _DATA_OBJ:
        _DATA_OBJ = DataLoader(config, experiment)
    elif not _DATA_OBJ.experiment.is_equal(experiment):
        _DATA_OBJ = DataLoader(config, experiment)
    return _DATA_OBJ


def get_sequence(_range, config, experiment):
    data_obj = _get_data_obj(config, experiment)
    return data_obj.get_sequence(_range)


class DataLoader(object):
    def __init__(self, config, experiment):
        self.experiment = experiment
        csv_config_file = experiment.csv_config
        csv_data_file = experiment.csv_data
        csv_config = {}
        try:
            with open(csv_config_file, 'r') as f:
                f_str = f.read()
                csv_config = json.loads(f_str)
            f.close()
        except IOError:
            print('Unable to load the configuration file')
        #
        self._load_csv(csv_data_file, csv_config)
        if config.input_size != self.input_size:
            msg = "Input size mismatched " + str(config.input_size) + " vs " + str(self.input_size)
            raise ValueError(msg)
    #
    def _load_csv(self, file_path, cols):
        df = pd.read_csv(file_path, sep=",")
        _filt = []
        for v in list(df):
            if v in cols and cols[v]:
                _filt.append(v)
        temp_df = df.filter(items=_filt)
        self.df = (temp_df - temp_df.mean()) / (temp_df.max() - temp_df.min()) 
        self.input_size = len(list(self.df))
    #
    def get_sequence(self, _range):
        return self.df.ix[_range].values.flatten()
#
