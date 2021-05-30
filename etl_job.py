# import etl_scripts
from etl_scripts import *

# enter database details
user = 'root'  # please write your user name
password = 'Docomo123@'  # please write your password
host = 'localhost'  # please write your host address
port = 3306
database = 'northwind'  # Please write your db/schema name you defined in SQL db
if __name__ == '__main__':

    # specifying the zip file name and zip file extract path
    zip_name = 'northwind_project/Data.zip'
    extract_path = 'northwind_project/'

    # Extract the data from zip file
    extract_zip(zip_name, extract_path)

    # Establish connection with SQL
    engine = establish_connection(user, password, host, database)

    # Write table name exists in SQL DB
    '''
    Write those table name first in the list, which has no foreign key associated.
    E.g. Check the store_db.sql file. products table has no foreign key associated, 
    hence it is added first in the list. orders table has associated foregin key, 
    hence added back in the table.
    '''

    # store_db
    # sql_table = ["products", "shippers", "customers", "order_statuses",
    #             "orders", "order_items"]

    # northwinf_db
    sql_table = ["categories", "customers", "suppliers", "employees",
                 "orders", "products", "order_details"]

    for table in sql_table:
        # path, where extracted data from zip is located
        path = 'northwind_project/Data/'
        data = transform_table(table, path, engine)
        print(data.shape)

        # insert data to sql
        insert_data_sql(data, table, engine)
