#!/usr/bin/bash

# @file createTable.sh
# @brief A script that creates a new table in a database.
# @example
#    ./createTable.sh tableName
# @arg $1 Table Name: should not contain any characters or contain only numbers.
# @exitcode 0 If successfully created a new table.
# @exitcode 1 If there is a syntax error in arguments or table name is not valid or table exists.
# ------------------------------------------------------------------------------------------------------
args="$@"

#Source the script containing test functions
source $HOME/octopusSQL/test.sh

#Source the script containing functions for inserting columns in table
source $HOME/octopusSQL/insertColumns.sh

#Print an error if no arguments or too many arguments are given.
if validName ${1}
then
  echo "ERROR: You have an error in your syntax, check the manual for the right syntax."
  exit 1
fi
columns=${args#"${1}"}
#Check if column names are repeated
REPEATED_COL_VALUE=$(echo "${columns}" | awk 'BEGIN{FS = ",";OFS = "\n"} {$1=$1} {print $0}' | sort | sed 's/^ //g' | cut -d " " -f 1 | uniq -i -c | sed 's/^ *//g')
REPEATED_COL_NAMES_FREQUENCY=$(echo ${REPEATED_COL_VALUE} | cut -d " " -f1) 
if [[ ${REPEATED_COL_NAMES_FREQUENCY} -gt 1 ]]
then
  echo "Duplicate column name '"$(echo "${REPEATED_COL_VALUE}" | cut -d " " -f2)"'"
  exit 1
fi	

#Put the second argument which is contains column names and data types into a variable
COLUMNS="${columns}"

#Get current directory name 
DIR=$(pwd | awk -F/ '{print $NF}')

#Check if a database is currently used , columns datatypes are valid, only one primary key is selected and is not assigned to a text.
if dbUsed && colDatatypeCheck "${COLUMNS}" && PKCheck "${COLUMNS}" && textPKCheck "${COLUMNS}"
then
  #Check if table name already exists
  if tableExist ${1} ${DIR}
  then
    echo "ERROR: Table '${1}' already exists."
    exit 1
  else
    #Add table name to tables list and create data file and metadata file containing the columns for the new table.
    echo "${1}" >> $HOME/octopusdb/${DIR}/tables.d
    touch $HOME/octopusdb/${DIR}/data/"${1}.d"
    touch $HOME/octopusdb/${DIR}/metadata/"${1}.md"
    insert ${1} "${columns}" 
    echo "${bold}Query Ok.${normal}"
    exit 0
  fi
fi

#If no database is currently used.
if ! dbUsed
then
  echo "ERROR: No database selected."
  
#If no columns are given.
elif [[ -z "${columns}" ]]
then
  echo "ERROR: A table must have at least 1 column."
  
#If multiple primary keys are assigned.
elif ! PKCheck "${COLUMNS}"
then
  echo "ERROR: Multiple primary key defined."
  
#If a primary key is assigned to a text.
elif ! textPKCheck "${COLUMNS}"
then
  echo "ERROR: Primary key constrain is assigned on a TEXT column."
  
else
  echo "ERROR: You have an error in your syntax, check the manual for the right syntax."
fi
exit 1

