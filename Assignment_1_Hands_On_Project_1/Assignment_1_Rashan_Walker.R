########################################################################
# Title:  Assignment 1: Hands On Project 1
# Author:  Rashan Walker
# Date Created:  2021-09-22
# Copyright statement / Usage Restrictions: None
# Contact Information: rwalk70@acd.ccac.edu  rashan.walker@gmail.com
# Notes:  (blank)
# 
#
#
########################################################################

# Function: roll_std_dice
# Create a six sided die
# Purpose: Simulate X (Default = 2) die rolls and sum those rolls
# Output: Sum of X  six sided die rolls

roll_std_dice <- function(x = 2) {
  die <- 1:6
  dice <- sample(die,size = x, replace = TRUE)
  sum(dice)
  
}

# Function: roll_dice
# Create a X sided die
# Purpose: Simulate Y rolls of an X sided die rolls and sum
# Output: Sum of Y X sided die rolls

roll_dice <- function(x = 6, y = 2) {
  die <- 1:x
  dice <- sample(die, size = y, replace = TRUE)
  sum(dice)
  
}



  #############  EOF #######################################################
