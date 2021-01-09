#!/usr/bin/bash

# @file dropTable.sh
# @brief A script that removes a given table from a database.
# @example
#    ./dropTable.sh tableName
# @arg $1 Table Name.
# @exitcode 0 If successfully dropped the table.
# @exitcode 1 If there is a syntax error in arguments or table doesn't exist.
# ------------------------------------------------------------------------------------------------------

#Source the script containing test functions
source $HOME/octopusSQL/test.sh

#Print an error if no arguments or too many arguments are given.
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
    #Remove table
    rm  $HOME/octopusdb/${DIR}/data/"${1}.d"
    rm  $HOME/octopusdb/${DIR}/metadata/"${1}.md"
    sed -i "/${1}/d" $HOME/octopusdb/${DIR}/tables.d
    echo "${bold}Query Ok.${normal}"
    exit 0
 
  #if table name does not exist
  else
    echo "ERROR: Can't drop table '${DIR}.${1}'.Table doesn't exist."
    exit 1
  fi
fi

#If database is not selected nor existed
echo "ERROR: No database selected."
exit 1


