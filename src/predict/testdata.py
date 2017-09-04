import numpy as np
import helper as hlp

#####################################################################################################################################
# Load data
## Malaga -> 'lemg'
## Granada -> legr
## Sevilla -> lezl
## Cordoba -> leba
## Cadiz, Jerez -> lejr
## Almeria, Huercal Overa -> leam
## Granada, Armilla -> lega
load_dir = '../../data/carga/'
forecast_dir = '../../data/proc/'
ext = '.csv'
files = [ ['57dab9ae0cbcfb4d060c50d9','legr'], ['57bed8afe1a2aa3043e858e0','legr'], ['57a2643efdd4fa09771fb7b6','lezl'], ['57a26399fdd4fa09771fb7b0','lezl'], ['5757cc555d5551982768b308','lemg'], ['5757c83e5d5551982768b301','lemg'], ['5757c5cc5d5551982768b2f8','lemg'], ['5757c1095d5551982768b2ef','lemg'], ['5757c0195d5551982768b2e9','lemg'], ['5757be795d5551982768b2e4','lemg'], ['5756e9795d5551982768b2d2','lemg'], ['5756e6095d5551982768b2c2','lemg'], ['5756e2cd5d5551982768b2b7','lemg'], ['5756e10a5d5551982768b2b0','lemg'], ['572b4abc6b4faac065df2c55','lemg'], ['572b25b16b4faac065df2c43','lemg'], ['5723113f8959448c58ddb37b','lemg'], ['570789a2f321773d033635d5','lemg'], ['56deeb10fed7cb5f739e40ab','legr'], ['56c5de770ae05714050d4861','lemg'], ['56c5daf20ae05714050d4829','lemg'], ['56c5d52c0ae05714050d480f','lemg'], ['56c5a0600ae05714050d47ec','lemg'], ['56c5802b0ae05714050d47d4','lemg'], ['56c57bba0ae05714050d47b7','lemg'], ['56c577880ae05714050d479f','lemg'], ['56c4a25d0ae05714050d4784','lemg'], ['56c497b10ae05714050d473f','lemg'], ['56c3488f0ae05714050d469a','lemg'], ['56c33abd0ae05714050d4665','lemg'], ['56c333670ae05714050d4648','lemg'], ['56c31bd90ae05714050d4611','lemg'], ['56c307260ae05714050d45e9','lemg'], ['56c2f7c3a1f84c08ff98f6cd','lemg'], ['56c2f7c3a1f84c08ff98f6c7','lega'], ['56c2f7c2a1f84c08ff98f6be','leba'], ['56c2f7c2a1f84c08ff98f6bb','legr'], ['56c2f7c1a1f84c08ff98f6af','lezl'], ['56c2f7c1a1f84c08ff98f6a6','lemg'], ['56c2f7c1a1f84c08ff98f6a0','lemg'], ['56c2eb84a221dcea2ed88d0f','lemg'], ['56c2e251a221dcea2ed88d03','lemg'], ['56b9b98a5918bd1148ef8c1a','lemg'], ['56b9b0ba5918bd1148ef8c0a','lemg'], ['56af7622e23cd6c566a8aa83','lemg'], ['569debfb93617a3c0f29c87b','leba'], ['5667fac6b69dc34e5b1a5b65','lemg'], ['5667f502b69dc34e5b1a5b5a','lemg'], ['5667f0c0b69dc34e5b1a5b57','lemg'], ['5667f02cb69dc34e5b1a5b54','lemg'], ['5667ed91b69dc34e5b1a5b4e','lemg'], ['5667ec7ab69dc34e5b1a5b4b','lemg'], ['5667eb61b69dc34e5b1a5b45','lemg'], ['56448ebe5de7a7ee647d4bf6','lemg'], ['56448ba67e5ba2df56afd103','lezl'] ]

def get_files(sel):
    load_file = load_dir + files[sel][0] + ext
    forecast_file = forecast_dir + files[sel][1] + ext
    return load_file, forecast_file

def get_load(sel):
    load_file, forecast_file = get_files(sel)
    load_curve = hlp.get_load(load_file)
    min_dt = load_curve[0].dt
    max_dt = load_curve[-1].dt
    forecast = hlp.get_forecast(forecast_file, min_dt, max_dt)
    # interpolate the weather forecast to match the load curve period
    forecast = hlp.interpolate_forecast(forecast, min_dt, max_dt)
    # TODO format data
    return load_curve, forecast

#####################################################################################################################################
# Synthetic data
def gen_data(size=1000000, dim=1):
    X = np.array(np.random.choice(2, size=(size,)))
#    X = np.array(np.random.choice(2, size=(size,dim)))
    Y = []
    for i in range(size):
        threshold = 0.5
        if np.all(X[i-3]) == True:
            threshold += 0.5
        if np.all(X[i-8]) == True :
            threshold -= 0.25
        if np.random.rand() > threshold:
            Y.append(0)
        else:
            Y.append(1)
    return X, np.array(Y)

def gen_batch(raw_data, batch_size, num_steps, dim):
    raw_x, raw_y = raw_data
    data_length = len(raw_x)
    # partition raw data into batches and stack them vertically in a data matrix
    batch_partition_length = data_length // batch_size
    data_x = np.zeros([batch_size, batch_partition_length], dtype=np.int32)
#    data_x = np.zeros([batch_size, batch_partition_length, dim], dtype=np.int32)
    data_y = np.zeros([batch_size, batch_partition_length], dtype=np.int32)
    for i in range(batch_size):
        data_x[i] = raw_x[batch_partition_length * i:batch_partition_length * (i + 1)]
        data_y[i] = raw_y[batch_partition_length * i:batch_partition_length * (i + 1)]
    # further divide batch partitions into num_steps for truncated backprop
    epoch_size = batch_partition_length // num_steps
    for i in range(epoch_size):
        x = data_x[:, i * num_steps:(i + 1) * num_steps]
        y = data_y[:, i * num_steps:(i + 1) * num_steps]
        yield (x, y)

def get_synth(epochs, num_steps, batch_size, size, dim):
    for i in range(n):
        yield gen_batch(gen_data(size, dim), batch_size, num_steps, dim)
