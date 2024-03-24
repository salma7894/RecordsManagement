#! /bin/bash


records_file_path="$PWD/$1.csv"
log_file="$PWD/$1.log"
record_name=""
record_amount=0
exist_in_records=0
selected_record=""
original_amount=0
record_row=0
is_file_empty=true


#create_records_file()-----------------------------------------------------#
#input: none 
#output: none
#--------------------------------------------------------------------------#
create_records_file()
{
	if [ ! -e "$records_file_path" ]
	then
		touch $records_file_path
	fi
}


#is_file_empty()----------------------------------------------------------#
#input: none 
#output: none
#-------------------------------------------------------------------------#
is_file_empty()
{
	if [ -s "$records_file_path" ]
	then
		is_file_empty="false"
	fi
}


#log()--------------------------------------------------------------------#
#input: action & status 
#output: writes to the log
#-------------------------------------------------------------------------#
log()
{
	local time_stamp=$(date +%d/%m/%y_%H:%M:%S | sed 's/_/ /g')
	local action=$1
	local status=$2
	

	if [ ! -f $log_file ] 
	then 
		touch $log_file
	fi

	case $action in
		"Insert")
			echo "$time_stamp Insert $status" >> $log_file;;
		"Delete")
			echo "$time_stamp Delete $status" >> $log_file;;
		"Search")
			echo "$time_stamp Search $status" >> $log_file;;
		"UpdateName")
			echo "$time_stamp UpdateName $status" >> $log_file;;
		"UpdateAmount")
			echo "$time_stamp UpdateAmount $status" >> $log_file;;
		"PrintAmount")
			echo "$time_stamp PrintAmount $status" >> $log_file;;
		"PrintAll")
			echo "$time_stamp PrintAll $status" >> $log_file;;
		*)
			;;
	esac
}


#records_menu()-------------------------------------------------------------------------#
#input: input record and function name
#output: selected record by the user
#----------------------------------------------------------------------------------------#
records_menu()
{


	local search_result=$(grep -i "$1" "$records_file_path" | tr '\n' '\n' | cut -d ',' -f 1)
	
	
	while IFS= read -r line;
	do
	if [ "$line" == "$1" ]
	then
	exist_in_records=1
	fi
	done <<< "$search_result"
	
	IFS=$'\n'
	

	
	if [ -z "$search_result" ]
	then
	if [ "$2" == "add_record" ]
	then 
	
	selected_record=$1
	log "Search" "Success"
	else
	        echo "The typed record doesn't exist in records file"
        log "Search" "Failure"
        fi
        else
        	if [ "$2" == "add_record" ] && [ $exist_in_records -eq 0 ]
        	then
        	select row in  $search_result $1;
        do
                case $row in
                        *)
			        selected_record="$row"
				log "Search" "success"
				break;;
                esac
        done
        	else
        	
	select row in  $search_result;
        do
                case $row in
                        *)
			        selected_record="$row"
				log "Search" "success"
				break;;
                esac
        done
        fi
fi


}


#amount_difference()------------------------------------------------------#
#input: record name 
#output: difference between the old amount and the new amount
#-------------------------------------------------------------------------#
amount_difference()
{
	old_amount=$(grep -i "$1" "$records_file_path" | cut -d ',' -f 2 | tr -d ' ')
	echo "old $old_amount $2"
	new_amount=$((old_amount - $2))
}


#record_row()-------------------------------------------------------------#
#input: record name
#output: extract the line that contains the record name
#-------------------------------------------------------------------------#
record_row()
{
	while IFS= read -r line;
	do
		tmp_record=$(grep -i "$line" "$records_file_path" | cut -d ',' -f 1 | tr -d ' ')  
	
		if [ "$tmp_record" == "$1" ]
		then
			record_row="$line"
		fi
	done < $records_file_path
}


#original_amount()--------------------------------------------------------#
#input: record name
#output: the amount
#-------------------------------------------------------------------------#
original_amount()
{
	record_row $1
	original_amount=$(echo "$record_row" | cut -d ',' -f 2 | tr -d ' ')
}


#update_amount()----------------------------------------------------------#
#input: record name and amount 
#output: update the selected amount
#-------------------------------------------------------------------------#
update_amount()
{
	local amount=$2
	if [ "$selected_record" = "" ];
        then
		log "UpdateAmount" "Failure"
		echo "UpdateAmount failed"
       	else
	       	if [ $2 -lt 1 ]
		then
			echo "The typed amount is less than 1"
			log "UpdateAmount" "Failure"
			echo "UpdateAmount failed"
                else
			original_amount $selected_record
			record_row $selected_record
		
			sed -i "s/$record_row/$selected_record, $((original_amount + amount))/g" "$records_file_path"
			log "UpdateAmount" "Success"
			echo "UpdateAmount succeded"
		fi
	fi

}


#update_name()------------------------------------------------------------#
#input: record name
#output: update the selected record name
#-------------------------------------------------------------------------#
update_name()
{
	if [ "$selected_record" = "" ];
        then
		log "UpdateName" "Failure"
		echo "UpdateName failed"
       	else
		sed -i "s/$selected_record/$2/g" "$records_file_path"
		echo "UpdateName succeeded"
		log "UpdateName" "Success"
       	fi

}


#delete_record()----------------------------------------------------------#
#input: record name
#output: deletes the record name
#-------------------------------------------------------------------------#
delete_record()
{
	if [ "$selected_record" = "" ]
	then
		log "Delete" "Failure"
	else
		amount_difference $selected_record $2
		
		
		if [ $new_amount -gt 0 ]
		then
		       	record_row $selected_record
		       	sed -i "s/$record_row/$selected_record"," $new_amount/g" "$records_file_path"

		elif [ $new_amount -eq 0 ]
		then
			sed -i "/$selected_record/d" "$records_file_path"
		else 
			sed -i "/$selected_record/d" "$records_file_path"
			echo "The typed amount is more than the existed amount"
		fi
		        echo "Delete record succeded"
			log "Delete" "Success"
	fi
}


#print_amount()------------------------------------------------------------#
#input: none 
#output: print the sum of all records
#-------------------------------------------------------------------------#
print_amount()
{
	local a=0
	local b=0
	
	while IFS= read -r line; do
		b=$(echo "$line" | cut -d ',' -f 2 | tr -d ' ')
		let a=a+b
	done < "$records_file_path"
	
	if [ $a -gt 0 ]
	then 
		echo "Number of records: $a"
		log "PrintAmount" "Success"
	else
		echo "There is no records"
		log "PrintAmount" "Failure"
	fi
}


#sort_records()-----------------------------------------------------------#
#input: none 
#output: prints the records sorted
#-------------------------------------------------------------------------#
sort_records()
{
	if [ -s "$records_file_path" ];
	then
		sort -t ',' -k 1 "$records_file_path"
		log "PrintAll" "Success"
	else
		echo "There is no records"
		log "PrintAll" "Failure"
	fi
}


#search()-----------------------------------------------------------------#
#input: record name
#output: list of all the records that contain the typed record name
#-------------------------------------------------------------------------#
search()
{
	local result=$(grep -i "$1" "$records_file_path" | cut -d ',' -f 1 | sort | tr '\n' '\n')
	
	if [ -z "$result" ];
       	then
		echo "No matching records"
		log "Search" "Failure"
	else
		grep -i "$1" "$records_file_path" | cut -d ',' -f 1 | sort | tr '\n' '\n' | while IFS= read -r line;
	do
		printf "%s\n" "$line"
		log "Search" "Success"
	done
	fi
}


#add_record()-------------------------------------------------------------#
#input: record name and amount 
#output: add the record to the file
#-------------------------------------------------------------------------#
add_record()
{
	records_menu "$record_name" "add_record"
	is_file_empty
	
	if [ "$is_file_empty" == "true" ]
	then
	        echo "$selected_record, $record_amount" >> $records_file_path
		echo "Record added successfully111"
		log "Insert" "Success"
		else
	if [ "$record_name" == "$selected_record" ] && [ $exist_in_records -eq 0 ]  
	then
		echo "$selected_record, $record_amount" >> $records_file_path
		echo "Record added successfully222"
		log "Insert" "Success"
	else
		update_amount "$selected_record" "$record_amount"
		echo "Record added successfully333"
		log "Insert" "Success"
	fi
	fi

}


#read_input()-------------------------------------------------------------#
#input: none
#output: asks the user to write an input
#-------------------------------------------------------------------------#
read_input()
{
	read -p "Please enter record name: " record_name
	read -p "Please enter record amount: " record_amount
	validate_name $record_name
	validate_amount $record_amount
}


#validate_name()----------------------------------------------------------#
#input: record name
#output: if input is valid
#-------------------------------------------------------------------------#
validate_name()
{
	local pattern1='^[a-zA-Z0-9]*$'
	if ! [[ "$1" =~ $pattern1 ]]
	then
		echo "Inavlid name input"
		read -p "Please enter record name: " record_name
	fi
}


#validate_amount()----------------------------------------------------------#
#input: record amount
#output: if input is valid
#-------------------------------------------------------------------------#
validate_amount()
{
	local pattern2='^[0-9]+$'
	if ! [[ "$1" =~ $pattern2 ]]
	then
		echo "Inavlid amount input"
		read -p "Please enter record amount: " record_amount
	fi
}





#main script

create_records_file
is_file_empty

select action in "Add record" "Delete record" "Search record" "Update record name" "Update record amount" "Print the amount of all records" "Print sorted records" "Exit";
do
	case $action in
		"Add record")
			read_input
			add_record $record_name $record_amount
			;;
		"Delete record")
			read_input
			records_menu $record_name "delete_record"
			delete_record $record_name $record_amount
			;;
		"Search record")
			read -p "Please enter record name: " record_name
			validate_name $record_name
			search $record_name
			;;
		"Update record name")
			read -p "Please enter old record name: " record_name
			validate_name $record_name
			read -p "Please enter new record name: " new_record_nam
			validate_name $new_record_name
			records_menu $record_name "update_name"
			update_name $record_name $new_record_name
			;;
		"Update record amount")
			read_input
			records_menu $record_name "update_amount"
			validate_amount $record_amount
			update_amount $record_name $record_amount
			;;
		"Print the amount of all records")
			print_amount
			;;
		"Print sorted records")
			sort_records
			;;
		"Exit")
			echo "Exiting from Records Management program"
			exit 0
			;;
		*)
			echo "You have selected an option that doesn't exist!"
			;;
	esac
done
