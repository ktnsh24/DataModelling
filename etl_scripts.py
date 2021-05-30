'''
etl_scripts include all the functions used in etl_jobs.py scripts.
'''

# importing required modules
# Standard library imports
import pandas as pd

# Third party imports
from zipfile import ZipFile
from sqlalchemy import inspect, create_engine


# This function will extract the zip file

def extract_zip(zip_name, extract_path):
    # opening the zip file in READ mode
    with ZipFile(zip_name, 'r') as zip:
        # extracting all the files
        print('Extracting all the files now...')
        zip.extractall(extract_path)
        count_zip = len(zip.infolist())
        print('total zip extracted', count_zip)
    return


# This function will establish the connection with MySQL

def establish_connection(user, password, host, database):
    path = 'mysql+pymysql://' + user + ':' + password + '@' + host + '/' + database
    engine = create_engine(path)
    print('Connection sucessfully established with engine', engine)
    return engine


# This fucntion extract the column name from MySQL table

def sql_table_column(table, engine_name):
    col_names = [col["name"]
                 for col in inspect(engine_name).get_columns(table)]
    print('column names are %s for table %s' % (col_names, table))
    return col_names


# This function will transform the table

def transform_table(table_name, file_path, engine_name):
    Header = sql_table_column(table_name, engine_name)
    path = file_path + table_name + ".csv"
    print("file path is ", path)
    # to read table
    #data = pd.read_table(path, sep='|', names=Header, index_col=False)
    # to read csv
    data = pd.read_csv(path, sep=',', names=Header, index_col=False)
    data = data.dropna(how='all', axis='columns')
    print(data.head())
    print('Table %s is tranformed' % (table_name))
    return data


# This function will insert the data from python to MySQL DB

def insert_data_sql(data, sql_tablename, engine):
    print('Data is trying to insert for table ' + sql_tablename)
    try:
        with engine.connect() as conn, conn.begin():
            data.to_sql(sql_tablename, conn, if_exists='append',
                        index=False, index_label=True)
    except Exception as e:
        print('Data could not be inserted for table ' + e)
    print('Data is inserted for table ', sql_tablename)
    return
