#!/bin/bash

# @file deleteRecord.sh
# @brief A script that deletes a record from a table.
# @example
#    ./deleteRecord.sh tableName record 
# @arg $1 Table Name.
# @arg $2 The record given in the following syntax where you can specify multiple columns: COLUMN=VALUE COLUMN=VALUE
# @exitcode 0 If successfully deleted the record.
# @exitcode 1 If there is a syntax error in arguments or table doesn't exist or no database is currently used 
#    or the record doesn't exist 
# -------------------------------------------------------------------------------------------------------

args="$@"

# Source Script containing test functions
source $HOME/octopusSQL/test.sh

#Check if a database is currently used.
if ! dbUsed
then
  echo "ERROR: No database selected."
  exit 1
fi
# ------------------------------------------------------------------------------------------------------
#Check if no arguments are given
if ! argsCheck ${#} 0
then
  echo "ERROR: You have an error in your syntax, check the manual for the right syntax."
  exit 1
fi
# ------------------------------------------------------------------------------------------------------
#Check if table exists in the current selected database.
if ! tableExist ${1} ${DIR}
then
  echo "ERROR: Table '"${DIR}.${1}"' doesn't exist."
  exit 1
fi
# ------------------------------------------------------------------------------------------------------
#if only table name is given then delete the whole table
if ! argsCheck ${#} 1
then
  cat /dev/null > $HOME/octopusdb/${DIR}/data/${1}.d
  exit 0
fi
# ------------------------------------------------------------------------------------------------------
#Put input arguments into an array
ARGS=("${@}")
#set -x
# Extract conditions from arguments
CONDITIONS=($(echo "${ARGS[@]:1}"))

# Get number of Conditions
CONDITIONS_NUM=$(echo $[${#}-1])

# Put the columns of the conditions into an array
# Put the the value of each column an array
INDEX=0
while [ ${INDEX} -lt ${CONDITIONS_NUM} ]
do 
  COLS+=("$(echo "${CONDITIONS[@]}" | cut -d "," -f $[${INDEX}+1] | cut -d "=" -f 1  | sed 's/^ *//g')")
  VALUES+=("$(echo "${CONDITIONS[@]}" | cut -d "," -f $[${INDEX}+1] | cut -d "=" -f 2)")
  let INDEX=${INDEX}+1
done

# Array containing number of field for each column to be able to access it in the data file
declare -a FIELDS
# ------------------------------------------------------------------------------------------------------
#Check that inserted fields exist in the table metadata
INDEX=0
while [ ${INDEX} -lt ${CONDITIONS_NUM} ]
do
  if ! cut -d ":" -f 1 $HOME/octopusdb/${DIR}/metadata/${1}.md | grep -x "${COLS[${INDEX}]}" > /dev/null
  then
    echo "ERROR: Unknown column '"${COLS[${INDEX}]}"'."
    exit 1
  fi
  let INDEX=${INDEX}+1
done
# ------------------------------------------------------------------------------------------------------
#Get field number of each input
INDEX=0
while [ ${INDEX} -lt ${CONDITIONS_NUM} ]
do
  FIELDS+=($(cut -d ":" -f 1 $HOME/octopusdb/${DIR}/metadata/${1}.md | grep -n -x "${COLS[${INDEX}]}" | cut -d ":" -f 1))
  let INDEX="${INDEX}"+1
done
# ------------------------------------------------------------------------------------------------------
#Get all records that match any of the conditions
declare -a RECORDS_LINES
INDEX=0
while [ ${INDEX} -lt ${CONDITIONS_NUM} ]
do
  RECORDS_LINES+=($(cut -d ":" -f ${FIELDS[${INDEX}]} $HOME/octopusdb/${DIR}/data/${1}.d | grep -n -x "${VALUES[${INDEX}]}" | cut -d ":" -f 1))
  let INDEX=${INDEX}+1
done
# ------------------------------------------------------------------------------------------------------
#Get frequency of each unique record line

#Get unique record line numbers (remove repeated numbers) 
UNIQUE_RECORDS=($(echo "${RECORDS_LINES[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

declare -a RECORDS_FREQ
SUM=0
for RECORD in "${UNIQUE_RECORDS[@]}"
do
  for LINE in "${RECORDS_LINES[@]}"
  do
    if [[ ${RECORD} -eq ${LINE} ]]
    then
      let SUM=${SUM}+1
    fi
  done
  RECORDS_FREQ+=(${SUM})
  let SUM=0
done
# ------------------------------------------------------------------------------------------------------
#Delete the records that appeared as many times as the number of conditions
INDEX=0
for FREQ in "${RECORDS_FREQ[@]}"
do
  if [[ ${FREQ} -eq ${CONDITIONS_NUM} ]]
  then
    DELETED_LINES+=("${UNIQUE_RECORDS[${INDEX}]}")
  fi
  let INDEX=${INDEX}+1
done
DELETED_RECORDS=$(echo "${DELETED_LINES[@]}" | sed 's/ /d;/g' | sed 's/$/d/')

# ------------------------------------------------------------------------------------------------------
#Delete the records
if [[ "${DELETED_RECORDS}" != d ]]
then
  sed -i "${DELETED_RECORDS}" $HOME/octopusdb/${DIR}/data/${1}.d 
  echo "${bold}Query Ok.${normal}"
else
  echo "${bold}Query Ok. No matching records.${normal}" 
fi
exit 0
