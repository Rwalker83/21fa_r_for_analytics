########################################################################
# Title:  Final Project
# Author:  Rashan Walker
# Date Submitted: 2021-12-16
# Copyright statement / Usage Restrictions: None
# Contact Information: rwalk70@acd.ccac.edu  rashan.walker@gmail.com
# Notes:  (blank)
# 
#
#
########################################################################

##########
# Setup
##########

library(DBI)
library(RSQLite)
library(reticulate)
library(scales)
library(tidyverse)

source_python('final_project.py')

##########
# Functions
##########

# Function: load_rb_data
# Purpose: Load Rebrickable.com bulk download data
# Input(s): None
# Output(s): None
# Notes: Uses Python to get the Rebrickable data

load_rb_data <- function() {
  py$download_files_rb()
  py$unzip_to_csv()
  py$convert_csv_json()
  py$csvs_to_sql()
}

# Function: connect_db
# Purpose: Connect to a a SQLite database
# Input(s): Path to the database
# Output(s): SQLite connection
# Notes: Default value for the path is "./data/lego.db"

connect_db <- function(db_path="./data/lego.db") {
  db_connect <- DBI::dbConnect(RSQLite::SQLite(), dbname=db_path)
  return(db_connect)
}

# Function: query_sql
# Purpose: Send a query to get 
# Input(s): A query in quotes ""
# Output(s): The result of the query as a tibble
# Notes: This function closes the database connection

query_sql <- function(statement) {
  connection <- connect_db()
  result <- dbGetQuery(connection, statement)
  result <- as_tibble(result)
  dbDisconnect(connection)
  return(result)
}

# Function: list_tables
# Purpose: list tables in a Database 
# Input(s): Database path
# Output(s): a list of tables
# Notes: This function also closes the database connection

list_tables <- function(db_path="./data/lego.db") {
  connection <- connect_db(db_path)
  result <- dbListTables(connection)
  dbDisconnect(connection)
  return(result)
}

# Function: list_fields
# Purpose: list tables in a Database 
# Input(s): Database path
# Output(s): a list of tables
# Notes: This function also closes the database connection

list_fields <- function(name, db_path="./data/lego.db") {
  connection <- connect_db(db_path)
  result <- dbListFields(connection, name)
  dbDisconnect(connection)
  return(result)
} 

# Function: get_table
# Purpose: Get a whole table from a database
# Input(s): Database path
# Output(s): a table as a tibble
# Notes: This function also closes the database connection

get_table <- function(table, db_path="./data/lego.db") {
  connection <- connect_db(db_path)
  result <- tbl(connection, table)
  result <- as_tibble(result)
  dbDisconnect(connection)
  return(result)
} 

# Function: write_table
# Purpose: Write a table to a database
# Input(s): Database path
# Output(s): (None)
# Notes: This function also closes the database connection

write_table <- function(data, name, db_path="./data/lego.db") {
  connection <- connect_db(db_path)
  dbWriteTable(connection, name, data)
  dbDisconnect(connection)
} 

# Function: ppp_by
# Purpose: Write a table to a database
# Input(s): Database path
# Output(s): (None)
# Notes: This function also closes the database connection

ppp_by <- function(name, data) {
  result <- data %>% 
    group_by_(name) %>% 
    summarise(ppp = mean(retailPrice/pieces, na.rm=TRUE), n=n()) %>% 
    arrange(desc(ppp))
  return(result)
} 

# Function: ppp_by
# Purpose: Write a table to a database
# Input(s): Database path
# Output(s): (None)
# Notes: This function also closes the database connection

clean_brickset_dates <- function(data) {
  result <- data %>%
   mutate(date_first = as.Date(dateFirstAvailable)) %>%
    mutate(date_last = as.Date(dateLastAvailable)) %>%
  return(result)
}



##########
# Execution
##########
