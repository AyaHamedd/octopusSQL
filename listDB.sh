#!/bin/bash

# @file listDB.sh
# @brief A script that lists the databases in the system.
# @noargs
# @exitcode 0 If successfully listed databases.
# @exitcode 1 If system doens't contain any database.
# ------------------------------------------------------------------------------------------------------

#Source the script containing test functions
source $HOME/octopusSQL/test.sh

#Print an error if any arguments is given
if argsCheck ${#} 0
then
  echo "ERROR: You have an error in your syntax, check the manual for the right syntax."
  exit 1
fi	

#Check if there is no databases then inform user
if dbSetEmpty
then
	echo "${bold}Empty set.${normal}"
	exit 1
else
	source $HOME/octopusSQL/printTable.sh $HOME/octopusdb/databases.d $HOME/octopusdb/databases.md
	exit 0
fi


