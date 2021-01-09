#!/bin/bash

# @file printTable.sh
# @brief A script that prints a file that contains records in a structured table. 
# @example
#    ./printTable.sh tableData.d tableMetadata.md
# @arg $1 The file that contains the records.
# @arg $2 The file that contains column names.
# @exitcode 0 If successfully printed the table.
# @exitcode 1 If there is a syntax error in arguments or files don't exist.
# ----------------------------------------------------------------------------------------------

# @description A Function to create a horizontal line based on the longest string size.
#   Dashes: keeps track of number of dashes being displayed.
#   Column: Column number. Used as an index to the arrays containing info related to each column.
#   Longest_Field: An array containing the longest field in each column.
# @noargs

function horizontal_line {
DASHES=-1
COLUMN=0

#Loop through columns
while [ ${COLUMN} -lt ${COLUMNS_NUM} ]
do
  echo -n '+'
  
  #Loop through the largest field and print the dashes
  while [[ ${DASHES} -le ${LONGEST_FIELD[$COLUMN]} ]]
  do
    echo -n '-'
    let DASHES=${DASHES}+1
  done
  
  let COLUMN=${COLUMN}+1 
  DASHES=-1
done
echo '+'
}

# @description A function that draws the table given the datafile and metadata.
#   Column: Column number. Used as an index to arrays containing info related to each column.
#   Field: A variable used to extract a certain field from files.
#   Record: Record number. U	sed to traverse through all records in a file.
# @noargs

function table {

#Create a horizontal border in the table
horizontal_line

#Reset variables
FIELD=1
RECORD=1
COLUMN=0

#Insert Column names in the first row
echo -n '|'

#Print Column names (attributes)
while [ ${COLUMN} -lt ${COLUMNS_NUM} ]
do
  #Get the field value
  STRING="$(echo "$(cut -d ':' -f 1 ${2} | sed -n "${FIELD}p")")"
  #Get the longest field of this column
  let LENGTH=${LONGEST_FIELD[$COLUMN]}+1
  printf " %-${LENGTH}s" $STRING
  let COLUMN=${COLUMN}+1
  let FIELD=${FIELD}+1
  printf "|"
done
echo ''

#Close column names with a horizontal line
horizontal_line

#Insert Records
while [ ${RECORD} -le ${RECORDS_NUM} ]
do
  COLUMN=0
  FIELD=1
  echo -n '|'
  while [ ${COLUMN} -lt ${COLUMNS_NUM} ]
  do
    STRING=$(echo "$(cut -d ':' -f ${FIELD} ${1} | sed -n "${RECORD}p" )")
    let LENGTH=${LONGEST_FIELD[$COLUMN]}+1
    printf " %-${LENGTH}s" "$STRING"
    let COLUMN=${COLUMN}+1
    let FIELD=${FIELD}+1 
    printf "|"
  done
  echo ''
  let RECORD=${RECORD}+1
done

#Insert last horizontal line
horizontal_line
}

#--------------------------------- End of funtions definitions ------------------------------------ #

#Check if arguments were less or more than required then exit 
if [ $# -ne 2 ]
then
  echo "Invalid arguments error."
  exit 1
fi


#Check if the provided files exist
if [[ ! -f "${1}" ]] || [[ ! -f "${2}" ]]
then
  echo "Invalid files error."
  exit 1
fi 


#Get no of columns from metadata file
COLUMNS_NUM=$( wc -l < ${2} )


#Save the length of each Column Title in an array
ATTRIBUTE_LENGTH=($(awk -F: '{print length($1)}' ${2}))


#Get number of records in the table
RECORDS_NUM=$(wc -l < ${1} )


#Get longest field in each column
COLUMN=0
FIELD=1

while [ ${COLUMN} -lt ${COLUMNS_NUM} ]
do
  LONGEST_FIELD[$COLUMN]=$(cut -d ':' -f ${FIELD} ${1} | awk '{print length}' | sort -n | tail -1)
  
  #Compare between the longest field and longest attribute
  if [[ "${ATTRIBUTE_LENGTH[$COLUMN]}" -gt "${LONGEST_FIELD[$COLUMN]}" ]]
  then
    let LONGEST_FIELD[$COLUMN]=${ATTRIBUTE_LENGTH[$COLUMN]}
  fi
  let COLUMN=${COLUMN}+1
  let FIELD=${FIELD}+1
done

#Call the funtion that prints the table
table ${1} ${2}
