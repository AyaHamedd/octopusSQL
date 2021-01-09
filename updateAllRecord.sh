#!/bin/bash

# @file updateRecord.sh
# @brief A script that updates specific records.
# @arg $1 Table Name.
# @arg $2 Conditions given in the following syntax : COLUMN=VALUE,COLUMN=VALUE , Where the last one is the updated value
# @exitcode 0 If successfully updated the record.
# @exitcode 1 If there is a syntax error in arguments or table doesn't exist or no database is currently used 
#    or the record doesn't exist 
# -------------------------------------------------------------------------------------------------------

# Source Script containing test functions
source $HOME/octopus/test.sh

#Check if a database is currently used.
if ! dbUsed
then
  echo "ERROR: No database selected."
  exit 1
fi
DB_DIR=$HOME/octopusdb/$DIR
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
  cat /dev/null > ${DB_DIR}/data/${1}.d
  exit 0
fi

column=$( echo "$@" |cut -d' ' -f2 | cut -d'=' -f1)
value=$( echo "$@" |cut -d' ' -f2 | cut -d'=' -f2)

# ------------------------------------------------------------------------------------------------------
#Check that inserted fields exist in the table metadata
if ! cut -d ":" -f 1 ${DB_DIR}/metadata/${1}.md | grep -x ${column} > /dev/null
then
    echo "ERROR: Unknown column '"${COLS[${INDEX}]}"'."
    exit 1
fi


# ------------------------------------------------------------------------------------------------------
#Get field number of Column
FIELD=$(cut -d ":" -f 1 ${DB_DIR}/metadata/${1}.md | grep -n -x ${column} | cut -d ":" -f 1)
PK_FIELD=$(grep -n "PRIMARY_KEY" ${DB_DIR}/metadata/${1}.md | cut -d ":" -f 1)

# Check if user is updating a primary key that already exists or is assigning same primary key for multiple records
if [ ${PK_FIELD} -eq ${FIELD} ] 
then
	echo  "ERROR: Can't assign the same value for key 'PRIMARY' in multiple records."
	exit 1
fi


# ------------------------------------------------------------------------------------------------------
# Check if user is updating an int column that the value is an integer and within limits
grep  "${column}" $DB_DIR/metadata/${1}.md | grep "INT" > /dev/null
INT_CHECK="$?"
grep  "${column}" $DB_DIR/metadata/${1}.md | grep "PRIMARY_KEY" > /dev/null
PK_CHECK="$?"

if [ ${INT_CHECK} -eq 0 ] || [ ${PK_CHECK} -eq 0 ]
   then 
      #If datatype of column is INT and Updated value contains anything but numbers raise an error
      if [[ ! ${value} =~ ^-?[0-9]+$ ]]
      then 
         echo "Incorrect integer value: ${value} for column ${column}."
         exit 1
      fi

      #If datatype of column is INT and Updated value in out of INT range raise an error
      if [ ${#value} -gt 11 ]
      then
         echo "Out of range value for column ${column}. "
         exit 1
       fi
       
       #If datatype of column is INT and Updated value in out of INT range raise an error
       if [ ${value} -lt -2147483648 ] || [ ${value} -gt 2147483647 ]
       then
          echo "Out of range value for column ${column}. "
    	exit 1
       fi
fi
# ------------------------------------------------------------------------------------------------------

#update required field in the specified record and save output in a temp file
awk -v val="$value" 'BEGIN{FS=":"; OFS=":";} {{$'${FIELD}'= val} print $0}'  $DB_DIR/data/${1}.d > $DB_DIR/metadata/_temp.d 

#Move temp file content to the original table to update it
mv $DB_DIR/metadata/_temp.d  $DB_DIR/data/${1}.d 		  
echo "${bold}Query Ok.${normal}"
exit 0
