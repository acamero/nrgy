from datetime import datetime, timedelta
import re

class Load(object):
    def __init__(self, dt, value):
        self.dt = dt
        self.value = value
#

class Forecast(object):
    def __init__(self, dt, sky, temperature, wind, humidity, pressure):
        self.dt = dt
        self.sky = sky
        self.temperature = temperature
        self.wind = wind
        self.humidity = humidity
        self.pressure = pressure
#


def get_load(filename, start_date=datetime.min, end_date= datetime.max, delimiter=';'):
    """ Convert a csv file into a Load object
    in
        filename: path to the csv file
        start_date: minimum date to include in the output
        end_date: maximum date to include in the output
        delimiter: character used to delimit the fields
    out
        load_curve: list of Load objects"""
    load_curve = list()
    with open(filename, "r") as input_file:
        next(input_file)
        for line in input_file:
            dt_str, load_str = line.split(delimiter)
            try:
                dt = datetime.strptime(dt_str, '%Y-%m-%d %H:%M')
                if start_date <= dt and dt <= end_date:
                    load_curve.append( Load(dt, float(load_str)) )
            except Exception, e:
                print e
        #
    #
    input_file.close()
    return load_curve


def get_forecast(filename, start_date= datetime.min, end_date= datetime.max, delimiter='|'):
    """ Convert a csv file of weather forecast into a list of Forecast objects"""
    forecast = list()
    with open(filename, "r") as input_file:
        for line in input_file:
            dt_str, t_str, sky_str, temp_str, wind_str, humidity_str, pressure_str = line.split(delimiter)
            try:
                dt = datetime.strptime(dt_str + ' ' + t_str, '%Y-%m-%d %H:%M')
                if start_date <= dt and dt <= end_date:
                    if temp_str == 'N/D':
                        temperature = 0.0
                    else:
                        temperature = int(re.findall(r'\d+', temp_str)[0])
                    if wind_str == 'En calma':
                        wind = 0.0
                    else:
                        wind = float(re.findall(r'\d+', wind_str)[0])
                    humidity = float(re.findall(r'\d+', humidity_str)[0])
                    pressure = float(re.findall(r'\d+', pressure_str)[0])
                    forecast.append( Forecast(dt, sky_str, temperature, wind, humidity, pressure) )
            except Exception, e:
                print e
        #
    #
    input_file.close()
    return forecast


def mean_forecast_interp(new_dt, fc1, fc2):
    temperature = (fc1.temperature + fc2.temperature) / 2.0
    wind = (fc1.wind + fc2.wind) / 2.0
    humidity = (fc1.humidity + fc2.humidity) / 2.0
    pressure = (fc1.pressure + fc2.pressure) / 2.0
    return Forecast(new_dt, fc1.sky, temperature, wind, humidity, pressure)


def interpolate_forecast(forecast, start_date= datetime.min, end_date= datetime.max, period=timedelta(minutes=15)):
    interp_forecast = list()
    actual_date = start_date
    # get the closest forecast
    idx = 0
    len_forecast = len(forecast)
    while idx < len_forecast  and forecast[idx].dt < actual_date:
        idx += 1
    # begin interpolation
    while actual_date <= end_date:
        if actual_date == forecast[idx].dt:
            interp_forecast.append( forecast[idx] )
            idx += 1
        elif actual_date < forecast[idx].dt:
            # interp last interp forecast with the next forecast
            if not interp_forecast:
                interp_forecast.append( mean_forecast_interp(actual_date, forecast[idx], forecast[idx]) )
            else:
                interp_forecast.append( mean_forecast_interp(actual_date, interp_forecast[-1], forecast[idx]) )
        else: # actual_date > forecast[idx].dt
            next_idx = idx + 1
            while next_idx < len_forecast and forecast[next_idx].dt < actual_date:
                next_idx += 1
            if next_idx >= len_forecast:
                next_idx = len_forecast - 1 
            interp_forecast.append( mean_forecast_interp(actual_date, forecast[idx], forecast[next_idx]) )
            idx += 1
        if idx >= len_forecast:
            idx = len_forecast - 1
        actual_date = actual_date + period
    #
    return interp_forecast



