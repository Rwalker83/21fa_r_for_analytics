########################################################################
# Title:  Assignment 2: Hands On Project 2
# Author:  Rashan Walker
# Date Created:  2021-10-21
# Copyright statement / Usage Restrictions: None
# Contact Information: rwalk70@acd.ccac.edu  rashan.walker@gmail.com
# Notes:  (blank)
# 
#
#
########################################################################


###########
# Functions
###########

# Function: load_deck
# Load a .csv
# Purpose: Turn a .csv file into a deck of cards 
# Output: A deck of cards
# Notes: (blank)

load_deck <- function(file_path_f = "./raw_data/deck.csv") {
  deck_f <- read.csv(file_path_f, stringsAsFactors = FALSE) 
}

##### DOESN'T WORK
# Function: clear
# Load a .csv
# Purpose: Clear the R environment
# Output: None
# Notes: Scoping needs updating to work

clear <- function() {
  rm(list = ls(all.names = TRUE))
  print("Enviroment Cleared")
}

##### Works
# Function: deal_card
# Deal a card from a deck
# Purpose: Deal one card from a deck
# Output: The top card from the deck
# Notes: (blank)

deal_card <- function(deck_f) {
  card <- deck_f[1, ]
  assign(deparse(substitute(deck_f)), deck_f[-1, ], envir = globalenv())
  card
}


#### Works
# Function: shuffle_deck
# Shuffle a deck
# Purpose: Shuffle the deck
# Output: A shuffled deck
# Notes: Expects a deck of 52 cards, as that is what it returns

shuffle_deck  <- function(deck_f) {
  random <- sample(1:52, size = 52)
  assign(deparse(substitute(deck_f)), deck_f[random, ], envir = globalenv())
}


##### DOESN'T WORK
# Function: change_value_suit
# Change deck suit faces
# Purpose: Change all the values of a suit
# Output: A deck with the suit values changed
# Notes: Expects a properly formatted deck

change_value_suit  <- function(deck_f, suit_f = "spades", value_f = 100) {
  deck_f$value[deck_f$suit == suit_f] <- value_f
  assign(deparse(substitute(deck_f)), deck_f, envir = globalenv())

}

##### DOESN'T WORK
# Function: change_value_face
# Change deck face values
# Purpose: Change all the values of a type of card
# Output: A deck with the face values changed
# Notes: Expects a properly formatted deck

change_value_face  <- function(deck_f, face_f = "ace", value_f = 100) {
  deck_f$value[deck_f$face == face_f] <- value_f
  assign(deparse(substitute(deck_f)), deck_f, envir = globalenv())
  
}

##### DOESN'T WORK
# Function: change_value_card
# Change the value of a specific card in the deck
# Purpose: Change the values of a specific card
# Output: A deck with that card's value changed
# Notes: Expects a properly formatted deck

change_value_card  <- function(deck_f, suit_f = "spades", face_f = "ace", value_f = 100) {
  deck_f$value[deck_f$suit == suit_f & deck_f$face == face_f] <- value_f
  print(deck_f)
  # assign(deparse(substitute(deck_f)), deck_f, envir = globalenv())
  
}

################################################################################

##########
# Execution
##########

deck <- load_deck()
deck2 <- deck
deck3 <- deck
deck4 <- deck
deck5 <- deck

##########
# Instructions
#
# Use console
##########


