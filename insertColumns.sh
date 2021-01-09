#!/usr/bin/bash

# @file insertColumns.sh
# @brief A script that contains test functions and insert funtions for columns into a table
# @noargs
# -------------------------------------------------------------------------------------------

# @description The function checks if the datatypes of columns are valid or not.
# @arg $1 column names and datatypes in the following syntax: col1Name datatype constrain,col2Name datatype constrain ..etc
# @returncode 0 If valid
# @returncode 1 If not valid.

function colDatatypeCheck () {
CHECK=$(echo "${1}" | awk 'BEGIN{FS = ",";OFS = "\n"} {$1=$1} {print $0}' | sed 's/^ //g' | awk '{if (($2 != "INT" && $2 != "TEXT") || ($1 == "INT" || $1 == "TEXT" || $1 == "PRIMARY_KEY") || ($3 != "PRIMARY_KEY" && $3 != "")) {print 1;exit 1}}') 

if [[ ${CHECK} -eq 1 ]]
then
  return 1
else
  return 0
fi 
}

# -------------------------------------------------------------------------------------------
# @description The function checks if primary key data type is repeated
# @arg $1 column names and datatypes in the following syntax: col1Name datatype constrain,col2Name datatype constrain ..etc
# @returncode 0 If not repeated
# @returncode 1 If repeated.

function PKCheck () {
CHECK=$(echo "${1}" | awk 'BEGIN{FS = ",";OFS = "\n"} {$1=$1} {print $0}' | grep -n "PRIMARY_KEY" | wc -l | cut -d ":" -f 1)
if [[ ${CHECK} -gt 1 ]]
then
  return 1
else
  return 0
fi 
}

# -------------------------------------------------------------------------------------------
# @description The function checks if primary key is assigned to text data type
# @arg $1 column names and datatypes in the following syntax: col1Name datatype constrain,col2Name datatype constrain ..etc
# @returncode 0 If not assigned
# @returncode 1 If assigned

function textPKCheck () {
PK_FIELD=$(echo "${1}" | awk 'BEGIN{FS = ",";OFS = "\n"} {$1=$1} {print $0}' | grep -n "PRIMARY_KEY" | cut -d ":" -f 1)
TEXT_FIELD=$(echo "${1}" | awk 'BEGIN{FS = ",";OFS = "\n"} {$1=$1} {print $0}' | grep -n "TEXT" | cut -d ":" -f 1)

#If text datatype is found then Check if primray key and text are on the same field 
if [[ ${PK_FIELD} = ${TEXT_FIELD} ]] && [[ ${PK_FIELD} -gt 0 ]] && [[ ${TEXT_FIELD} -gt 0 ]]
then
  return 1
else
  return 0
fi 
}

# ----------------------------------------------------------------
# @description The function inserts column names and datatypes into table metadata file.
# @arg $1 column names and datatypes in the following syntax: col1Name datatype constrain,col2Name datatype constrain ..etc

function insert () {
METADATA_PATH="$HOME/octopusdb/${DIR}/metadata/${1}.md"
TEMP_PATH="$HOME/octopusdb/${DIR}/metadata/temp.md"

#Convert the input argument from one line into multiple lines based on the separator ","
echo "${2}" | awk 'BEGIN{FS = ",";OFS = "\n"} {$1=$1} {print $0}' > ${METADATA_PATH}

#Remove any leading space in any input
sed -i 's/^ //g' ${METADATA_PATH}

#Change all the space separators into :
awk 'BEGIN{OFS = ":"} {$1=$1} {print $0}' ${METADATA_PATH} > ${TEMP_PATH}

#Move temp file content to the original metadata
mv ${TEMP_PATH}  ${METADATA_PATH}
}
