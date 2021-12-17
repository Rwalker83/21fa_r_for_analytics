########################################################################
# Title:  Assignment 3: Hands On Project 3
# Author:  Rashan Walker
# Date Created:  2021-10-28
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

# Function: get_symbols
# Purpose: Produce three symbols of weighted probabilities
# Output: 3 symbols as strings
# Notes: (blank)

get_symbols <- function() {
  wheel <- c("DD", "7", "BBB", "BB", "B", "C", "0")
  sample(wheel, size = 3, replace = TRUE, 
         prob = c(0.03, 0.03, 0.06, 0.1, 0.25, 0.01, 0.52))
}

# Function: score
# Purpose: Score a roll
# Output: The score or payout of the roll
# Notes: (blank)

score <- function(symbols) {
  
  # Cheeries and Diamonds
  cherries <- sum(symbols == "C")
  diamonds <- sum(symbols == "DD")
  
  # Setup
  slots <- symbols[symbols != "DD"]
  same <- length(unique(slots)) == 1
  bars <- slots %in% c("B", "BB", "BBB")
  
  # Payout table
  payouts <- c("7" = 80, "BBB" = 40, "BB" = 25,
               "B" = 10, "C" = 10, "0" = 0)
  
  # Score Logic Tree
    if (diamonds == 3) {
    prize <- 100  
  }
    else if(same) {
    # All the same symbols
    prize <- unname(payouts[slots[1]])
  } else if(all(bars)) {
    # All bars but not the same bars
    prize <- 5
  } else if(cherries >0) {
    # Cherries
    prize <- c(0, 2, 5)[cherries + diamonds + 1]
  } else {
    prize <- 0
  }

  # Diamond adjustment
  prize * 2 ^ diamonds
}

# Function: slot_display
# Purpose: Display slot game output
# Output: A "prettier" output of teh slot game
# Notes: (blank)

slot_display  <- function(prize) {
  
  # Get symbols
  symbols <- attr(prize, "symbols")
  
  # Collapse symbols into a dtring
  symbols <- paste(symbols, collapse = " ")
  
  # Combine symbol with prize in a string
  string <- paste(symbols, prize, sep = "\nPrize: $")
  
  # Display string without qoutes
  cat("Spin:", string)
  
}


# Function: play
# Purpose: Play a slot game
# Output: Print and score the result of a slot roll
# Notes: (blank)

play <- function() {
  symbols <- get_symbols()
  structure(score(symbols), symbols = symbols, class = 'slots')
  
}

# Function: play_till_zero
# Purpose: Play a slot game until no money
# Output: Number of plays till no money 
# Notes: Default inputs are start with 100, and play cost 1

play_till_zero <- function(start_with = 100, play_cost = 1) {
  
  cash <- 100
  n <- 0
  
  repeat {
    cash <- cash - play_cost + play()
    n <- n + 1
    if (cash <= 0) {
      break
    }
  }
  n
}

################################################################################

##########
# Execution / Testing
##########
wheel <- c("DD", "7", "BBB", "BB", "B", "C", "0")
prob <- c("DD" = 0.03, "7" = 0.03, "BBB" = 0.06, "BB" = 0.1, "B" = 0.25, 
          "C" = 0.01, "0" = 0.52)
combos <- expand.grid(wheel, wheel, wheel, stringsAsFactors = FALSE)
combos
combos$prob1 <- prob[combos$Var1]
combos$prob2 <- prob[combos$Var2]
combos$prob3 <- prob[combos$Var3]
head(combos, 3)
combos$prob <- combos$prob1 * combos$prob2 * combos$prob3
sum(combos$prob)
symbols <- c(combos[1, 1], combos[1, 2], combos[1, 3])
score(symbols)
for (i in 1:nrow(combos)) {
  symbols <- c(combos[i, 1], combos[i, 2], combos[i, 3])
  combos$prize[i] <- score(symbols)
}
head(combos, 3)
sum(combos$prize)
sum(combos$prize * combos$prob)
play_till_zero()
##########
# Instructions
#
# Use console
##########