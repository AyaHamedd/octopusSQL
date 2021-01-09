#!/bin/bash

# @file selectRecord.sh
# @brief A script that displays a specific record in a table.
# @example
#    ./selectRecord.sh tableName record
# @arg $1 Table Name.
# @arg $2 The record given in the following syntax COLUMN=VALUE
# @exitcode 0 If successfully displayed the record.
# @exitcode 1 If there is a syntax error in arguments or no database is currently used
#   or table doesn't exist or the record doesn't exist.
# ------------------------------------------------------------------------------------------------------

# Source Script containing test functions
source $HOME/octopusSQL/test.sh

# Print an error if less than two arguments are given
if [ $# -lt 2 ]
then
  echo "ERROR: You have an error in your syntax, check the manual for the right syntax."
  exit 1
fi	

# ------------------------------------------------------------------------------------------------------
# Check if a database is currently used.
if ! dbUsed
then
  echo "ERROR: No database selected."
  exit 1
fi

# ------------------------------------------------------------------------------------------------------
# Check if table exists in the current selected database.
if [ ! ${1} = "_temp" ] && ! tableExist ${1} ${DIR}
then
  echo "ERROR: Table '"${DIR}.${1}"' doesn't exist."
  exit 1
fi
# ------------------------------------------------------------------------------------------------------
# Put input arguments into an array
ARGS=(${@})

# Extract conditions from arguments
CONDITIONS=($(echo "${ARGS[@]:1}"))

# Get number of Conditions
CONDITIONS_NUM=$(echo $[${#}-1])

# Put the columns of the conditions into an array
COLS=($(echo "${CONDITIONS[@]%=*}"))

# Put the the value of each column an array
VALUES=($(echo "${CONDITIONS[@]#*=}"))

# Array containing number of field for each column to be able to access it in the data file
declare -a FIELDS

# ------------------------------------------------------------------------------------------------------
# Check that inserted fields exist in the table metadata
INDEX=0
while [ ${INDEX} -lt ${CONDITIONS_NUM} ]
do
  if ! cut -d ":" -f 1 $HOME/octopusdb/${DIR}/metadata/${1}.md | grep -x ${COLS[${INDEX}]} > /dev/null
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
  FIELDS+=($(cut -d ":" -f 1 $HOME/octopusdb/${DIR}/metadata/${1}.md | grep -n -x ${COLS[${INDEX}]} | cut -d ":" -f 1))
  let INDEX="${INDEX}"+1
done
# ------------------------------------------------------------------------------------------------------
#Get all records that match any of the conditions
INDEX=0
declare -a RECORDS_LINES
while [ ${INDEX} -lt ${CONDITIONS_NUM} ]
do
  RECORDS_LINES+=($(cut -d ":" -f ${FIELDS[${INDEX}]} $HOME/octopusdb/${DIR}/data/${1}.d | grep -n -x ${VALUES[${INDEX}]} | cut -d ":" -f 1))
  let INDEX=${INDEX}+1
done
# ------------------------------------------------------------------------------------------------------
# Get frequency of each unique record line

#Get unique record line numbers (remove repeated numbers) 
UNIQUE_RECORDS=($(echo "${RECORDS_LINES[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

declare -a RECORDS_FREQ
FREQ=0
for RECORD in "${UNIQUE_RECORDS[@]}"
do
  for LINE in "${RECORDS_LINES[@]}"
  do
    if [[ ${RECORD} -eq ${LINE} ]]
    then
      let FREQ=${FREQ}+1
    fi
  done
  RECORDS_FREQ+=(${FREQ})
  let FREQ=0
done
# ------------------------------------------------------------------------------------------------------
#Select the records that appeared as many times as the number of conditions
INDEX=0
for KEY in "${RECORDS_FREQ[@]}"
do
  if [[ ${KEY} -eq ${CONDITIONS_NUM} ]]
  then
    SELECTED_LINES+=("${UNIQUE_RECORDS[${INDEX}]}")
  fi
  let INDEX=${INDEX}+1
done

# ------------------------------------------------------------------------------------------------------
#Display Selected Records
SELECTED_RECORDS=$(echo "${SELECTED_LINES[@]}" | sed 's/ /p;/g' | sed 's/$/p/')

#Select records
if [[ "${SELECTED_RECORDS}" != p ]]
then
  #Get Whole record and put in a file so we can pass it to printTable
  sed -n "${SELECTED_RECORDS}" $HOME/octopusdb/${DIR}/data/${1}.d > $HOME/octopusdb/${DIR}/metadata/record.d
  source $HOME/octopusSQL/printTable.sh $HOME/octopusdb/${DIR}/metadata/record.d $HOME/octopusdb/${DIR}/metadata/${1}.md
  
  #Delete Record file
  rm $HOME/octopusdb/${DIR}/metadata/record.d
else
  echo "${bold}Query Ok. No matching records.${normal}" 
fi
exit 0
