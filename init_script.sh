#!/bin/bash

# Define the processes you want to check and start
process_names=("mariadb" "nginx" "php8.2-fpm" "snmpd")

while true; do
    # Loop through the process names
    for process_name in "${process_names[@]}"; do
        # Check if the process is running
        service "$process_name" status > /dev/null
	if [ $? -eq 3 ]; then
            echo "Process $process_name is not running. Starting it..."
            
            service $process_name start &

            echo "Process $process_name started."
        else
            echo "Process $process_name is already running."
        fi
    done

    # Adjust the sleep duration based on your needs
    sleep 5
done

