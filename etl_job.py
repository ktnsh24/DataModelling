# import etl_scripts
from etl_scripts import *

# enter database details
user = 'root'  # please write your user name
password = 'password'  # please write your password
host = 'localhost'  # please write your host address
port = 3306
# use 'northwind_schema', if you're working with northwind_project.
database = 'store_schema'
if __name__ == '__main__':

    # specifying the zip file name and zip file extract path
    # use 'northwind_project/Data.zip', if you're working with northwind_project.
    zip_name = 'store_project/Data.zip'
    # use 'northwind_project/', if you're working with northwind_project.
    extract_path = 'store_project/'

    # Extract the data from zip file
    extract_zip(zip_name, extract_path)

    # Establish connection with SQL
    engine = establish_connection(user, password, host, database)

    # Write table name exists in SQL DB
    '''
    In the list, write those table name first, which has no foreign key associated.
    E.g. Check the store_db.sql file. products table has no foreign key associated, 
    hence it is added first in the list. orders table has associated foregin key, 
    hence added back in the table.
    '''

    # store_schema
    sql_table = ["products", "shippers", "customers", "order_statuses",
                 "orders", "order_items"]

    # northwind_schmea
    '''
    In the below sql table, I have purposley changed the order of the table name. 
    It's a challenge to correct the table name order. 
    Above, I've described the way how to write these table names in correct order
    '''
    # sql_table = [ "suppliers", "employees",
    #             "products", "categories","customers","orders"]

    for table in sql_table:
        # path, where extracted data from zip is located
        # use 'northwind_project/Data/', if you're working with northwind_project.
        path = 'store_project/Data/'
        data = transform_table(table, path, engine)
        print(data.shape)

        # insert data to sql
        insert_data_sql(data, table, engine)
