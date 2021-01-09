#!/usr/bin/bash

# @file octopus.sh
# @brief A script that handles the UI with the user where it process all requires queries and runs the corresponding scripts.
# @noargs
# -------------------------------------------------------------------------------------------------------
# Turn of expansion
set -f
#set -x
declare -i index

#check if octopusdb doens't exist then create one 
test -d $HOME/octopusdb
if [ $? -eq 1 ]
then 
	mkdir $HOME/octopusdb
	touch $HOME/octopusdb/databases.d
	touch $HOME/octopusdb/databases.md
	echo "Databases" > $HOME/octopusdb/databases.md
fi

function getIndex(){
	args=("$@")
	string="${args[0]}"
	i=1
	for key in "${args[@]:1}"
	do
   		if [[ "${key}" = "${string}" ]] 
   		then
       		index=$i;
       		return
   		fi
   		let i=$i+1
	done
}
# -------------------------------------------------------------------------------------------------------
function Create(){
	local args=("$@")
	if [ "${args[0]}" = "DATABASE" ]
	then 
    		bash $HOME/octopusSQL/createDB.sh "${args[@]:1}"
    	elif [ "${args[0]}" = "TABLE" ]
    	then 
    		if [ "${#args[@]}" -lt 3 ]
    		then
    			echo "ERROR 5 : You have an error in your SQL syntax."
    		else
    			bash $HOME/octopusSQL/createTable.sh "${args[1]}" "${args[@]:2}"
    		fi
    	else 
    		echo "ERROR 1 : You have an error in your SQL syntax."
	fi      
	}
# -------------------------------------------------------------------------------------------------------
function Drop(){
	local args=("$@")
	if [ "${args[0]}" = "DATABASE" ]
	then 
    		bash $HOME/octopusSQL/dropDB.sh "${args[@]:1}"
    	elif [ "${args[0]}" = "TABLE" ]
    	then 
    		bash $HOME/octopusSQL/dropTable.sh "${args[@]:1}"
    	else 
    		echo "ERROR 1 : You have an error in your SQL syntax."
	fi   }
# -------------------------------------------------------------------------------------------------------
function Show(){
	local args=("$@")
	if [ "${args[0]}" = "DATABASES" ]
	then 
    		bash $HOME/octopusSQL/listDB.sh "${args[@]:1}"
    	elif [ "${args[0]}" = "TABLES" ]
    	then 
    		bash $HOME/octopusSQL/listTables.sh "${args[@]:1}"
    	else 
    		echo "ERROR 3 : You have an error in your SQL syntax."
	fi   
}
# -------------------------------------------------------------------------------------------------------
function Select(){
	local args=("$@")
	local arg=("$@")
	argsNum="${#args[@]}"
    	if [[ "${args[@]}" =~ "FROM" ]]
    	then 
    		if [ "${args[0]}" = "*" ] && [ "${args[1]}" = "FROM"  ]
		then 
    			bash $HOME/octopusSQL/showTable.sh "${args[@]:2}"
    			return 0
    		fi
    		
    		getIndex "FROM" "${args[@]}" 
    		
    		if [ "${argsNum}" -eq ${index} ]
    		then
    			return 1
    		fi
    		
    		let tableIndex=$index+1
		DIR=$(pwd | awk -F/ '{print $NF}')
    		table="${args[${tableIndex}]}"	
    		bash $HOME/octopusSQL/showcols.sh $table "${args[@]:1:${index}-1}"
    		if [[ "${args[@]}" =~ "WHERE" ]]
    		then
    		       getIndex "WHERE" "${arg[@]}"
    		       if [ "${argsNum}" -eq ${index} ]
    		       then
    		       	return 1
    		       fi
    		       bash $HOME/octopusSQL/selectRecord.sh "_temp" "${args[@]:${index}+1}"
    		       
    		       
		else
    		      source $HOME/octopusSQL/printTable.sh $HOME/octopusdb/${DIR}/data/_temp.d $HOME/octopusdb/${DIR}/metadata/_temp.md
    		fi
				 
	fi  
	return 0
	}
	
# -------------------------------------------------------------------------------------------------------
function Insert(){
	local args=("$@")
	echo $args
    	if [ "${#args[@]}" -lt 2 ]
    	then
    		echo "ERROR 5 : You have an error in your SQL syntax."
    	else
    		bash $HOME/octopusSQL/insertRecord.sh "${args[0]}" "${args[@]:1}"
    	fi    
	}
	
# -------------------------------------------------------------------------------------------------------
function Delete(){
	local args=("$@")
	local arg=("$@")
	argsNum="${#args[@]}"
	if [[ "${args[1]}" =~ "WHERE" ]]
	then
		bash $HOME/octopusSQL/deleteRecord.sh "${args[0]}" "${args[2]}" "${args[@]:3}"
	else
		bash $HOME/octopusSQL/deleteRecord.sh "${args[0]}"
        fi	  
	}
# -------------------------------------------------------------------------------------------------------
function Update(){
	local args=("$@")
	local arg=("$@")
	argsNum="${#args[@]}"
    	if [[ "${args[1]}" =~ "SET" ]]
    	then 
    	    	if [[ "${args[@]}" =~ "WHERE" ]]
    		then 
    			getIndex "WHERE" "${args[@]}" 
    		
    			if [ "${argsNum}" -eq ${index} ]
    			then
    				echo "ERROR : You have an error in your SQL syntax."
    				return 1
    			fi 
    		       bash $HOME/octopusSQL/updateRecord.sh "${arg[0]}" "${args[@]:${index}+1}"  ", ${arg[@]:2:${index}-3}"
    		else
    			bash $HOME/octopusSQL/updateAllRecord.sh "${arg[0]}"  "${arg[@]:2}"
		fi
    	else
    		echo "ERROR 10 : You have an error in your SQL syntax."
				 
	fi  
	return 0
	}
# -------------------"${QUERY[@]:1}"------------------------------------------------------------------------------------
#Source the script containing test functions
source $HOME/octopusSQL/test.sh

#clear Terminal
clear

#Print menu and read input from user
echo "Welcome to the OctopusDB monitor."

#Set a prompt for the program
prompt="octopusDB [(none)] >  "

while true
do
   	echo -n ${prompt}
   	read input
   	QUERY=(${input})
   	
   	
   	if [ ${QUERY[0]} = "CREATE" ]
   	then 
   	    Create "${QUERY[@]:1}"
    
   	elif [ ${QUERY[0]} = "DROP" ]
   	then
            Drop  "${QUERY[@]:1}"
              
        elif [ ${QUERY[0]} = "USE" ]
   	then
            source $HOME/octopusSQL/openDB.sh "${QUERY[@]:1}"
            
            
        elif [ ${QUERY[0]} = "SHOW" ]
   	then
            Show "${QUERY[@]:1}"


        elif [ ${QUERY[0]} = "SELECT" ]
   	then
            if ! Select "${QUERY[@]:1}"
            then 

            	echo " ERROR "
            fi
        elif [ ${QUERY[0]} = "INSERT" ] && [ ${QUERY[1]} = "INTO" ] 
   	 then
            Insert "${QUERY[@]:2}"
        elif [ ${QUERY[0]} = "DELETE" ] && [ ${QUERY[1]} = "FROM" ] 
   	then
            Delete "${QUERY[@]:2}"
        elif [ ${QUERY[0]} = "UPDATE" ]
   	then
            Update "${QUERY[@]:1}"
        else 
            echo "ERROR 10 : You have an error in your SQL syntax."
        fi
done
