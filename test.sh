#!/usr/bin/bash

# @file test.sh
# @brief A script that contains all test functions for validation.
# @noargs
# ----------------------------------------------------------------

#Variables used to print in bold.
bold=$(tput bold)
normal=$(tput sgr0)


# @description The function checks if number of args passed to a script corresponds to valid args number.
# @arg $1 number of arguments passed to the script.
# @arg $2 valid number of arguments for the script.
# @returncode 0 If valid.
# @returncode 1 If not valid.

function argsCheck () {
if [ ${1} -ne ${2} ] 
then
	return 0
else
	return 1
fi
}

# ----------------------------------------------------------------
# @description The function checks if a given name is valid; doesn't contain any characters or contains only numbers.
# @arg $1 name.
# @returncode 0 If valid.
# @returncode 1 If not valid.

function validName () {
if [[ ${1} =~ ^[0-9]+$ ]] || [[ ! ${1} =~ ^[a-zA-Z0-9][a-zA-Z0-9]*[a-zA-Z0-9]*$ ]]
then
	return 0
else	
	return 1
fi
}

# ----------------------------------------------------------------
# @description The function checks if a database exists or not.
# @arg $1 database name.
# @returncode 0 If exists.
# @returncode 1 If doesn't exist.

function dbExist () {
if grep -x ${1} $HOME/octopusdb/databases.d > /dev/null 
then
	return 0
else	
	return 1
fi
}
# ----------------------------------------------------------------
# @description The function checks if a table exists or in the current Database or not.
# @arg $1 table name.
# @arg $2 database name.
# @returncode 0 If exists.
# @returncode 1 If doesn't exist.

function tableExist () {
if grep -x ${1} $HOME/octopusdb/${2}/tables.d > /dev/null  2> /dev/null
then
	return 0
else	
	return 1
fi
}
# ----------------------------------------------------------------
# @description The function checks if the databases set in the system is empty.
# @noargs
# @returncode 0 If set is empty.
# @returncode 1 If set is not empty.

function dbSetEmpty () {
if [ -s $HOME/octopusdb/databases.d ]
then
	return 1
else	
	return 0
fi
}

# ----------------------------------------------------------------
# @description The function checks if the tables set in the database is empty.
# @arg $1 Database name
# @returncode 0 If set is empty.
# @returncode 1 If set is not empty.

function tableSetEmpty () {
if [ -s $HOME/octopusdb/${1}/tables.d ]
then
	return 1
else	
	return 0
fi
}

# ----------------------------------------------------------------
# @description The function checks if user is currently using a database.
# @noargs
# @returncode 0 If user is using a database.
# @returncode 1 If no database is being used

function dbUsed () {
DIR=$(pwd | awk -F/ '{print $NF}')
CHECK=$(awk -v DIRECTORY=${DIR} '{if (DIRECTORY==$0) {print 1}}' $HOME/octopusdb/databases.d)
if [[ "${CHECK}" -eq 1 ]]
then
	return 0
else	
	return 1
fi
}

# ----------------------------------------------------------------
# @description The function checks if a value is integer.
# @arg1 $1 Value
# @returncode 0 If integer.
# @returncode 1 If not.

#Function to check if the passed argument is integer or not
function intCheck () {
if [[ $1 =~ ^-?[0-9]+$ ]]
then
  return 0
else
  return 1
fi
}
