#!/bin/bash

# @file showTable.sh
# @brief A script that shows all records from a given table.
# @example
#    ./showTable.sh tableName
# @arg $1 Table name.
# @exitcode 0 If successfully displayed table records.
# @exitcode 1 If there is a syntax error in arguments or table name doesn't exist.
# ---------------------------------------------------------------------------------

#Source the script containing test functions
source $HOME/octopusSQL/test.sh

#Print an error if no arguments or too many arguments are given
if argsCheck ${#} 1
then
  echo "ERROR: You have an error in your syntax, check the manual for the right syntax."
  exit 1
fi	

#Get current directory name
DIR=$(pwd | awk -F/ '{print $NF}')

#Check if database exists and is currently used.(selected)
if dbUsed
then
  #Check if table name exists
  if tableExist ${1} ${DIR}
  then
    source $HOME/octopusSQL/printTable.sh $HOME/octopusdb/${DIR}/data/${1}.d $HOME/octopusdb/${DIR}/metadata/${1}.md 
    exit 0
  else
    echo "ERROR: Table ${1} doesn't exist."
    exit 1
  fi
else
  echo "ERROR: No database selected."
  exit 1
fi


