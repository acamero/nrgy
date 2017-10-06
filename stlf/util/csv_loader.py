import pandas

def csv_to_df(file_path):
    df = pd.read_csv(file_path, sep=",")


