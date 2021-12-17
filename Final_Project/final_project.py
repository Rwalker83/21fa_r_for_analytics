import csv
import glob
import gzip
import json
import os
import pandas
import re
import requests
import shutil
import sqlite3
import zipfile
from bs4 import BeautifulSoup
from requests import api

data_folder = './data/'
brickset_api_root = 'https://brickset.com/api/v3.asmx/'

headers = {'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36'}

def close_DB_Resources(dbconn):
    '''
    Purpose: Close a database connection
    Input: Database connection
    Default(s): NONE
    Output: NONE
    Notes: (blank)

    Credit == Github: lan33-ccac
    '''
    try:
        dbconn.close()
        print()
        print('DB resources were closed successfully.')
    except sqlite3.Error as error:
        print('Error occurred closing DB resources.', error)
 
def remove_file(file):
    '''
    Purpose: Delete a file
    Input: File path
    Default(s): NONE
    Output: NONE
    Notes: (blank)
    '''
    try:
        os.remove(file)
    except Exception as error:
        print("Error in function: remove_file()")
        print(error)

def show_files(top = '.'):
    '''
    Purpose: Show files in a folder
    Input: System Path
    Default(s): '.'
    Output: NONE
    Notes: (blank)
    '''
    try:
        for loc, dirs, files in os.walk(top):
            if loc == '.':
                print('***********************************************************')
                print('Files(s):', ', '.join(files))
                print('***********************************************************')
    except Exception as error:
        print("Error in function: show_files()")
        print(error)

def get_file(url, file_type='.csv.gz'):
    '''
    Purpose: Download a file
    Input: File Name and URL of file
    Default(s): File type of .csv.gz
    Output: (None)
    Notes: (Blank)
    '''
    path = './temp/'
    search = re.compile(r'\w+'+file_type)
    file_name = re.search(search, url).group(0)
    try:
        r = requests.get(url, headers = headers, allow_redirects=True)
        open(path+file_name, 'wb').write(r.content)
        print('Download Completed:', file_name)
    except Exception as error:
        print("Error in function: get_file()")
        print(error)

def get_links_ft(url='https://rebrickable.com/downloads/', file_type='.csv.gz'):
    '''
    Purpose: Parse a webpage for downloadable links based on file type
    Input: File Type and URL of file
    Default(s): File type of .csv.gz
    Output: Returns a list of links
    Notes: (blank)
    '''
    try:
        response = requests.get(url, headers=headers)
        soup = BeautifulSoup(response.content, 'html.parser')
        a_ft = soup.find_all('a', href=re.compile(f'{file_type}'))
        for links in a_ft:
            print(f'URL Found for the file type of {file_type}:', links['href'])
        return a_ft
    except Exception as error:
        print("Error in function: get_links_ft()")
        print(error)

def download_files_rb(url='https://rebrickable.com/downloads/'):
    '''
    Purpose: Download Rebrickable compressed database files
    Input: URL
    Default(s): Rebrickable downloads page
    Output: (None)
    Notes: (Blank)
    '''
    try:
        print("Here are the links:")
        links = get_links_ft(url, '.csv.gz')
        print("Downloading:")
        for link in links:
            get_file(link['href'], '.csv.gz')
        print("Downloading Finished.")
        
    except Exception as error:
        print("Error in function: download_files_rb()")
        print(error)

def gunzip(file_in, file_out):
    '''
    Purpose: Unzip a Gzip a file
    Input: File path in, File path out
    Default(s): (None)
    Output: (None)
    Notes: (Blank)
    '''
    try:
        with gzip.open(file_in, 'rb') as f_in:
            with open(file_out, 'wb') as f_out:
                shutil.copyfileobj(f_in, f_out)
                print(f'Unzipped {file_in} to {file_out}')
    except Exception as error:
        print("Error in function: gunzip()")
        print(error)

def unzip_to_csv(path_in = './temp/', file_type_i = '.csv.gz'):
    '''
    Purpose: Unzip all gz files to to ,csv
    Input: Path in and file type
    Default(s): Path in and file type
    Output: (None)
    Notes: (Blank)
    '''
    try:
        lst = []
        file_type_o = '.csv'
        path_out = './data/csv/'
        search = re.compile(r'\w+'+file_type_i)
        for f_path_i in glob.glob(f'{path_in}*{file_type_i}'):
            f_path_o = path_out+re.sub(file_type_i, file_type_o,re.search(search, f_path_i).group(0))
            lst_t = [f_path_i, f_path_o]
            lst.append(lst_t)
        for file in lst:
            gunzip(file[0],file[1])
    except Exception as error:
        print("Error in function: unzip_to_csv()")
        print(error)

def write_json(file_path_out, list_dict):
    with open(file_path_out, 'w', encoding="utf8") as file_out:
        json.dump(list_dict, file_out)
    print(f'JSON file written to {file_path_out}')

def read_csv(file_path_in):
    '''
    Purpose: read a csv file and convert it to JSON
    Input: File path in
    Default(s): (None)
    Output: (None)
    Notes: (Blank)
    '''
    try:
        with open(file_path_in, 'r', encoding="utf8") as file_in:
            file = csv.DictReader(file_in, delimiter=',')
            data_s0 = []
            for row in file:
                data_s0.append(row)
            data = data_s0
        data_name = os.path.splitext(os.path.basename(file_path_in))[0]
        file_path_out = f'./data/json/{data_name}.json'
        write_json(file_path_out, data)
    except Exception as error:
        print("Error in function: read_csv()")
        print(error)

def convert_csv_json(path_in='./data/csv/'):
    '''
    Purpose: Convert a directory of CSVs to JSONs
    Input: File path in
    Default(s): File path in
    Output: (None)
    Notes: (Blank)
    '''
    file_list = os.listdir(path_in)
    for file in file_list:
        read_csv(f'{path_in}{file}')

def csvs_to_sql(path_in='./data/csv/'):
    '''
    Purpose: Convert a directory of CSVs to SQL tables
    Input: File path in
    Default(s): File path in
    Output: (None)
    Notes: (Blank)
    '''
    try:
        dbconn = sqlite3.connect(data_folder+'lego.db')
        lst = []
        search = re.compile(r'\w+\.csv')
        for f_path_i in glob.glob('./data/csv/*.csv'):
            name = re.sub('.csv', '', re.search(search, f_path_i).group(0))
            lst_t = [f_path_i, name]
            lst.append(lst_t)
            pandas.read_csv(f_path_i).to_sql(name,dbconn,if_exists='replace')
            print(f'Table {name} has been loaded from:\n{f_path_i}')
        close_DB_Resources(dbconn)
    except Exception as error:
        print("Error in function: csvs_to_sql()")
        print(error)

def get_brickset_secrets(file_path ='./brickset.json'):
    '''
    Purpose: Use a JSON of secrets for use in the BrickSet API
    Input: File path in
    Default(s): File path in
    Output: apikey, username, password
    Notes: (Blank)
    '''
    apikey = ''
    username = ''
    password = ''
    
    try:
        with open(file_path, 'r') as keyfile:
            keydict = json.load(keyfile)
            apikey = keydict['apikey']
            username = keydict['username']
            password = keydict['password']
            return apikey, username, password
    except FileNotFoundError:
        print("Cound not find key file: ", file_path)
    except KeyError:
        print("Keyfile does not contain keyname")
    except Exception as error:
        print("Error in function: get_brickset_secrets()")
        print(error)

def check_brickset_api(apikey):
    '''
    Purpose: Check brickset apikey
    Input: apikey
    Default(s): (None)
    Output: Return the text of the API response
    Notes: (Blank)
    '''
    brickset_api_root = 'https://brickset.com/api/v3.asmx/'
    endpoint = f'checkKey?apiKey={apikey}'
    try:
        url = brickset_api_root + endpoint
        response = requests.get(url)
        if(int(response.status_code)==200):
            return response.text
        else:
            raise Exception("Non 200 status code")
    except Exception as error:
        print("Error in function: check_brickset_api()")
        print(error)

def get_brickset_hash(apikey,username,password):
    '''
    Purpose: Get userhash (login) for use with Brickset API 
    Input: Apikey, Username, Password
    Default(s): (None)
    Output: apikey, username, password
    Notes: (Blank)
    '''
    endpoint = f'login?apiKey={apikey}&username={username}&password={password}'
    try:
        url = brickset_api_root + endpoint
        response = requests.get(url)
        if(int(response.status_code)==200):
            r_json=response.json()
            return r_json['hash']
        else:
            raise Exception("Non 200 status code")
    except Exception as error:
        print("Error in function: get_brickset_hash()")
        print(error)

def get_brickset_sets(apikey,userHash,params={'owned':'1'}):
    '''
    Purpose: Retrive a dataset from the Brickset API based on parameters
    Input: Apikey, Userhash, Parameters
    Default(s): Parameters for owned sets
    Output: Json of results
    Notes: (Blank)
    '''
    endpoint = f'getSets?apiKey={apikey}&userHash={userHash}&params={params}'
    try:
        url = brickset_api_root + endpoint
        response = requests.get(url)
        if(int(response.status_code)==200):
            r_json=response.json()
            return r_json
        else:
            raise Exception("Non 200 status code")
    except Exception as error:
        print("Error in function: get_brickset_sets()")
        print(error)

def brickset_to_sql(dict_lst_dict, v_name, t_name):
    '''
    Purpose: Convert a Brickset Sets JSON to an AQL tab;e 
    Input: JSON, Dataset Name, Table NAme 
    Default(s): (None)
    Output: (None)
    Notes: Link to one-liner: https://stackoverflow.com/questions/14984119/python-pandas-remove-duplicate-columns
    '''
    try:
        clean_list = ['collection', 'collections', 'LEGOCom', 'ageRange', 'dimensions', 'barcode', 'extendedData', 'US']
        drop_list = ['UK', 'CA', 'DE']
        drop_list.append(clean_list)
        dbconn = sqlite3.connect(data_folder+'lego.db')
        df = pandas.DataFrame(dict_lst_dict[v_name])
        df.drop('image', axis=1, inplace=True)
        for column in clean_list:
            expanded = df[column].apply(pandas.Series)
            df = pandas.concat([df, expanded], axis=1)
        for column in drop_list:
            df.drop(column, axis=1, inplace=True)
        df = df.loc[:,~df.columns.duplicated()] # From Stack Overflow
        df.to_sql(t_name,dbconn,if_exists='replace')
        print(f'Table {t_name} has been loaded from: {v_name}')
        close_DB_Resources(dbconn)
    except Exception as error:
        print("Error in function: brickset_to_sql()")
        print(error)

apikey, username, password = get_brickset_secrets()
check_brickset_api(apikey)
userhash = get_brickset_hash(apikey, username, password)
owned_sets = get_brickset_sets(apikey, userhash,{'owned':'1'})
wanted_sets = get_brickset_sets(apikey, userhash,{'wanted':'1'})
brickset_to_sql(owned_sets,'sets','owned_sets')
brickset_to_sql(wanted_sets,'sets','wanted_sets')