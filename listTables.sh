#!/bin/bash

# @file listTables.sh
# @brief A script that lists tables inside a database
# @noargs
# @exitcode 0 If successfully listed tables.
# @exitcode 1 If database doesn't contain any tables.
# ------------------------------------------------------------------------------------------------------

#Source the script containing test functions
source $HOME/octopusSQL/test.sh

#Print an error if any argument is given
if argsCheck ${#} 0
then
  echo "ERROR: You have an error in your syntax, check the manual for the right syntax."
  exit 1
fi	

#Get current directory name
DIR=$(pwd | awk -F/ '{print $NF}')

#Check if database exists and is currently used.(selected)
if dbUsed
then
  if tableSetEmpty ${DIR}
  then
  	echo "${bold}Empty set.${normal}"
	exit 1
  else
  	source $HOME/octopusSQL/printTable.sh $HOME/octopusdb/${DIR}/tables.d $HOME/octopusdb/${DIR}/tables.md
  	exit 0
  fi
else
  echo "ERROR: No database selected."
  exit 1
fi


