#!/bin/bash

# @file showcols.sh
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
	
# ------------------------------------------------------------------------------------------------------
# Check if a database is currently used.
if ! dbUsed
then
  echo "ERROR: No database selected."
  exit 1
fi

# ------------------------------------------------------------------------------------------------------
# Check if table exists in the current selected database.
if ! tableExist ${1} ${DIR}
then
  echo "ERROR: Table '"${DIR}.${1}"' doesn't exist."
  exit 1
fi

# ------------------------------------------------------------------------------------------------------
args=("$@")

# Put columns in an array
COLS=("${args[@]:1}")
COLSNUM="${#COLS[@]}"

# Array containing number of field for each column to be able to access it in the data file
declare -a FIELDS

# ------------------------------------------------------------------------------------------------------
# Check that inserted fields exist in the table metadata
INDEX=0
while [ ${INDEX} -lt ${COLSNUM} ]
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
while [ ${INDEX} -lt ${COLSNUM} ]
do
  FIELDS+=($(cut -d ":" -f 1 $HOME/octopusdb/${DIR}/metadata/${1}.md | grep -n -x ${COLS[${INDEX}]} | cut -d ":" -f 1))
  let INDEX="${INDEX}"+1
done
# ------------------------------------------------------------------------------------------------------

echo "${FIELDS[*]}"

cut -d: -f "${FIELDS[*]}" $HOME/octopusdb/${DIR}/data/${1}.d > $HOME/octopusdb/${DIR}/data/_temp.d

line="${FIELDS[0]}p"
for key in "${FIELDS[@]:1}"
do
	line="${line};${key}p"
done
sed -n "${line}" $HOME/octopusdb/${DIR}/metadata/${1}.md > $HOME/octopusdb/${DIR}/metadata/_temp.md

exit 0
