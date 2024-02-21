#!/bin/bash

while true; do
    select option in create_database list_databases connect_to_database drop_database exit; do
        case $option in
            create_database)
                read -p "Please enter database name: " DBName
                case $DBName in
                    ""|*[[:space:]]*)
                        echo "Invalid database name. Name cannot be empty or contain spaces."
                        validName=false
                        ;;
                    *[!a-zA-Z]*)
                        echo "Invalid database name. Only letters are possible."
                        validName=false
                        ;;
                    *)
                        validName=true
                        ;;
                esac
                if [ "$validName" = true ]; then
                    if [ ! -e "$DBName" ]; then
                        mkdir "$DBName"
                        echo "Database '$DBName' is created successfully."
                    else
                        echo "Database '$DBName' already exists."
                    fi
                fi
                ;;
            list_databases)
                ls -d */
                ;;
            connect_to_database)
                read -p "please enter database name : " ConDB
                case $ConDB in
                    ""|*[[:space:]]*)
                        echo "Invalid database name. Name cannot be empty or contain spaces."
                        validName=false
                        ;;
                    *)
                        validName=true
                        ;;
                esac
                if [ "$validName" = true ]; then
                    if [ -e "$ConDB" ]; then
                        previous_directory=$(pwd)
                        cd "$ConDB"
                        current_directory=$(pwd)
                        cd "$previous_directory"
                        source ./tables.sh "$current_directory" "$ConDB"
                    else
                        echo "Database $ConDB does not exist."
                    fi
                fi
                ;;
            drop_database)
                read -p "please enter database name : " delDB
                case $delDB in
                    ""|*[[:space:]]*)
                        echo "Invalid database name. Name cannot be empty or contain spaces."
                        validName=false
                        ;;
                    *)
                        validName=true
                        ;;
                esac
                if [ "$validName" = true ]; then
                    if [ -e "$delDB" ]; then
                        rm -r "$delDB"
                        echo "Database $delDB is deleted successfully."
                    else
                        echo "Database $delDB does not exist."
                    fi
                fi
                ;;
            exit)
                echo "Exiting script."
                break 2  # Break out of both select and while loops
                ;;
            *)
                echo "Invalid option. Please select a valid option from the menu."
                ;;
        esac
    done
done
