#!/bin/bash

# @file openDB.sh
# @brief A script that opens a specific database for the user to start managing tables inside it. 
# @example
#    ./openDB.sh dbName
# @arg $1 Database Name.
# @returncode 0 If succesfully opened the database.
# @returncode 1 If database doesn't exist.
# ------------------------------------------------------------------------------------------------------

#Source the script containing test functions
source $HOME/octopusSQL/test.sh

#Print an error if no arguments or too many arguments are given.
if argsCheck ${#} 1
then 
	echo "ERROR: You have an error in your syntax, check the manual for the right syntax."
	rCode=1
	
#Check if the database exists
elif dbExist ${1}
then
	cd  $HOME/octopusdb/$1
	echo "${bold}Database changed.${normal}"
	prompt="octopusDB [${1}] > "
        rCode=0

#If database doesn't exist inform user.
else 
	echo  "ERROR: Can't open database '${1}'.Database doesn't exist."
	rCode=1
fi

