#!/usr/bin/bash

clear
echo "Connected successfully to $2 database"
cd "$1"

select option in create_table list_tables drop_table insert_into_table select_from_table delete_from_table update_table  Exit; do
    case $option in 

create_table)
 
    while true; do
        read -p "Please enter table name: " TBName
        if [ -z "$TBName" ]; then
            echo "Invalid table name. Name cannot be empty."
        elif [ -e "$TBName" ]; then
            echo "Table '$TBName' already exists."
        elif [[ "$TBName" =~ [0-9] ]]; then
            echo "Invalid table name. Name cannot contain numbers."
        else
            break
        fi
    done

   
    while true; do
        read -p "Please enter number of columns: " NumOfCol
        if ! [[ $NumOfCol =~ ^[0-9]+$ ]]; then
            echo "Invalid input. Please enter a valid number."
        elif [ -z "$NumOfCol" ]; then
            echo "Invalid input. Number of columns cannot be empty."
        else
            break
        fi
    done

   
    touch ".meta$TBName" 
    touch "$TBName" 
    echo "Table '$TBName' is created successfully."


    while true; do
        read -p "Please enter the name for the first column (primary key): " FirstColName
        if [ -z "$FirstColName" ]; then
            echo "Invalid column name. Name cannot be empty."
        elif [[ "$FirstColName" =~ [0-9] ]]; then
            echo "Invalid column name. Name cannot contain numbers."
        else
            break
        fi
    done


    echo "Please select column type for '$FirstColName' (integer/string): "
    select FirstColType in integer string; do
        case $FirstColType in
            integer|string)
                break
                ;;
            *)
                echo "Invalid input. Please select either 'integer' or 'string'."
                ;;
        esac
    done

 
    echo "$FirstColName:$FirstColType:pk" >> ".meta$TBName"


 for ((i=1; i<$NumOfCol; i++)); do
    while true; do
        read -p "Please enter Column name : " ColName
        if [ -z "$ColName" ]; then
            echo "Invalid column name. Name cannot be empty."
        elif [[ "$ColName" =~ [0-9] ]]; then
            echo "Invalid column name. Name cannot contain numbers."
        else
            break
        fi
    done

    line=""
    line+=$ColName

   
    while true; do
        echo "Please select column type for '$ColName' (integer/string): "
        select ColType in integer string; do
            case $ColType in
                integer|string)
                    break
                    ;;
                *)
                    echo "Invalid input. Please select either 'integer' or 'string'."
                    ;;
            esac
        done
        break
    done

    line+=":$ColType"
    echo "$line" >> ".meta$TBName"
 done 

 echo "Columns are created successfully."
 ;;

list_tables)
            ls -p | grep -v /
     ;;

drop_table)
    while true; do
        read -p "Please enter table name: " delTB
        if [ -z "$delTB" ]; then
            echo "Invalid input. Table name cannot be empty."
        else
            break
        fi
    done

    if [ -e "$delTB" ]; then
        rm "$delTB"
        echo "Table $delTB is deleted successfully."
    else 
        echo "Table $delTB does not exist."
    fi
    ;;
insert_into_table)
    read -p "Please enter table name: " insTB

    if [ -z "$insTB" ]; then
        echo "Invalid input. Table name cannot be empty."
    elif [ ! -e "$insTB" ]; then
        echo "Table $insTB does not exist."
    else
        file=".meta$insTB"
        columns_names=()
        columns_data_types=()

     
        while IFS=':' read -r column_name data_type _; do
            columns_names+=("$column_name")
            columns_data_types+=("$data_type")
        done < "$file"

        num_columns=${#columns_data_types[@]}
        line=""

       
read -p "Please enter ${columns_names[0]} value (numbers only): " PKValue


if [[ ! "$PKValue" =~ ^[0-9]+$ ]]; then
    echo "Invalid input! ${columns_names[0]} value must contain numbers only."
    continue  
fi


if grep -q "\<$PKValue\>" "$insTB"; then
    echo "Row with primary key '$PKValue' already exists. Try inserting a new value."
else
    valid_input=true
    line+="$PKValue "
           
            for ((i=1; i<$num_columns; i++)); do
                read -p "Please enter ${columns_names[$i]} value: " colValue

                case "${columns_data_types[$i]}" in
                    integer)
                        if [[ $colValue =~ ^[0-9]+$ ]]; then
                            line+="$colValue "
                        else
                            echo "Invalid input! ${columns_names[$i]} value must be an integer."
                            valid_input=false
                            break
                        fi
                        ;;
                    string)
                        if [[ $colValue =~ ^[a-zA-Z]+$ ]]; then
                            line+="$colValue "
                        else
                            echo "Invalid input! ${columns_names[$i]} value must be a string."
                            valid_input=false
                            break
                        fi
                        ;;
                    *)
                        echo "Unsupported data type: ${columns_data_types[$i]}"
                        valid_input=false
                        break
                        ;;
                esac
            done

            if [ $valid_input = true ]; then
                echo "$line" >> "$insTB"
                echo "Row inserted into $insTB table successfully."
            fi
        fi
    fi
    ;;





select_from_table)
    read -p "Please enter table name: " selTB
    if [ -z "$selTB" ]; then
        echo "Invalid input. Table name cannot be empty."
    elif [ ! -e "$selTB" ]; then
        echo "Table $selTB does not exist."
    elif [ ! -s "$selTB" ]; then
        echo "Table $selTB is empty."
    else
        cat "$selTB"
        echo
    fi
    ;;


delete_from_table)
    while true; do
        read -p "Please enter table name: " delTB
        if [ -z "$delTB" ]; then
            echo "Invalid input. Table name cannot be empty."
        elif [[ "$delTB" =~ [0-9] ]]; then
            echo "Invalid table name. Name cannot contain numbers."
        elif [ ! -e "$delTB" ]; then
            echo "Table $delTB does not exist."
        else
            break
        fi
    done

    while true; do
        read -p "Please enter primary key of the row you want to delete: " rowID
        if [ -z "$rowID" ]; then
            echo "Invalid input. Primary key cannot be empty."
        else
         
            if [[ ! "$rowID" =~ ^[0-9]+$ ]]; then
                echo "Invalid input. Primary key must be numeric."
            else
               
                value_exists=0
                if [ -e "$delTB" ]; then
                    if grep -q "\<$rowID\>" "$delTB"; then
                        value_exists=1
                    fi
                fi
                if [ "$value_exists" -eq 1 ]; then
                   
                    sed -i "/^$rowID /d" "$delTB"
                    echo "Row with primary key '$rowID' deleted from table $delTB."
                else
                    echo "Row with primary key '$rowID' does not exist in table $delTB."
                fi
                break
            fi
        fi
    done
    ;;

update_table)
    while true; do
        read -p "Please enter table name: " updTB
        if [ -z "$updTB" ]; then
            echo "Invalid input. Table name cannot be empty."
        elif [[ "$updTB" =~ [0-9] ]]; then
            echo "Invalid table name. Name cannot contain numbers."
        elif [ ! -e "$updTB" ]; then
            echo "Table $updTB does not exist."
        else
            break
        fi
    done

    read -p "please enter primary key of the row you want to update : " rowID
    if [ -z "$rowID" ]; then
        echo "Invalid input. primary key cannot be empty."
    else 
        file=".meta$updTB"
        columns_names=()
        columns_data_types=()

       
        while IFS=':' read -r column_name data_type _; do
            columns_names+=("$column_name")
            columns_data_types+=("$data_type")
        done < "$file"

        num_columns=${#columns_data_types[@]}
        line=""

        check_value_in_table() {
            local table="$1"
            local value_to_check="$2"
            local value_exists=0 

            if [ -e "$table" ]; then
                if grep -q "\<$value_to_check\>" "$table"; then
                    value_exists=1  
                fi
            fi

            return $value_exists
        }

        check_value_in_table "$updTB" "$rowID"
        value_exists=$?

        if [ "$value_exists" -eq 1 ]; then
            sed -i "/^$rowID /d" "$updTB"
            line+="$rowID "

            for ((i=1; i<$num_columns; i++)); do   
                read -p "please enter ${columns_names[$i]} value : " colValue
                case "${columns_data_types[$i]}" in
                    integer)
                        if [[ $colValue =~ ^[0-9]+$ ]]; then
                            valid_input=true
                            line+="$colValue "
                        else
                            echo "Invalid input! "
                            valid_input=false
                            break
                        fi
                        ;;
                    string)
                        if [[ $colValue =~ ^[a-zA-Z]+$ ]]; then
                            valid_input=true
                            line+="$colValue "
                        else
                            echo "Invalid input! "
                            valid_input=false
                            break
                        fi
                        ;;
                    *)
                        echo "Unsupported data type: ${columns_data_types[$i]}"
                        ;;
                esac
            done 
            echo "$line"
            if [ $valid_input = true ]; then 
                echo "$line"3
                echo "$line" >> "$updTB"
                echo "Row updated in $updTB table successfully"                
            fi
        else
            echo "Row with primary key : '$rowID' does not exist."
        fi
    fi
    ;;
    Exit)
    clear 
    cd ..
    source ./project.sh
;;
  esac 
done