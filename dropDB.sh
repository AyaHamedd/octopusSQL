#!/usr/bin/bash

# @file dropDB.sh
# @brief A script that removes a given database from the system. 
# @example
#    ./dropDB.sh dbName
# @arg $1 Database Name.
# @exitcode 0 If successfully dropped the database.
# @exitcode 1 If there is a syntax error in arguments or database doesn't exist.
# ------------------------------------------------------------------------------------------------------

# Source Script containing test functions
source $HOME/octopusSQL/test.sh

#Print an error if no arguments or too many arguments are given.
if argsCheck ${#} 1
then 
	echo "ERROR: You have an error in your syntax, check the manual for the right syntax."
	exit 1

#Check if database exists
elif dbExist ${1}
then
	#Remove Directory
	rm -r $HOME/octopusdb/$1
	sed -i "/$1/d" $HOME/octopusdb/databases.d
	echo "${bold}Query Ok.${normal}"
	exit 0
else
	echo "ERROR: Can't drop database '${1}'.Database doesn't exist."
	exit 1
fi

