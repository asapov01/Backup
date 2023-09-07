#!/bin/bash

function logo() {
    bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function printGreen {
    echo -e "\e[1m\e[32m${1}\e[0m"
}

clear
logo

printGreen "Бажаєте зробити backup нод: Lava, Nibiru, Subspace, Gear? (Y/N)"
read response

function backup() {
    if [[ $response == "Y" || $response == "y" ]]; then
        backup_dir="/root/BACKUPNODES"
        mkdir -p "$backup_dir"

        lava_source_dir="/root/.lava/"
        lava_files_to_copy=( "config/priv_validator_key.json" "config/node_key.json" "data/priv_validator_state.json" )
        lava_backup_dir="$backup_dir/Lava backup"

        gear_source_dir="/root/.local/share/gear/chains/gear_staging_testnet_v7/network/" 
        gear_files_to_copy=( "$gear_source_dir/secret_ed"* )
        gear_backup_dir="$backup_dir/Gear backup"

        subspace_source_dir="/root/.local/share/pulsar/node/chains/subspace_gemini_3f/network/"
        subspace_files_to_copy=( "$subspace_source_dir/secret_ed"* )
        subspace_backup_dir="$backup_dir/Subspace backup"

        nibiru_source_dir="/root/.nibid/"
        nibiru_files_to_copy=( "config/priv_validator_key.json" "config/node_key.json" "data/priv_validator_state.json" )
        nibiru_backup_dir="$backup_dir/Nibiru backup"

        backup_message_printed=false

        for lava_file_to_copy in "${lava_files_to_copy[@]}"; do
            if [ -f "$lava_source_dir/$lava_file_to_copy" ]; then
                backup_message_printed=true
                break
            fi
        done

        if [ "$backup_message_printed" == true ]; then
            echo ""
            printGreen "Копіюємо бекап файли ноди Lava в папку /root/BACKUPNODES/Lava backup" && sleep 1
            mkdir -p "$lava_backup_dir"
            for lava_file_to_copy in "${lava_files_to_copy[@]}"; do
                if [ -f "$lava_source_dir/$lava_file_to_copy" ]; then
                    echo "Збережено: $lava_file_to_copy" && sleep 1
                    cp "$lava_source_dir/$lava_file_to_copy" "$lava_backup_dir/"
                fi
            done
        fi

        backup_message_printed=false

        for gear_file_to_copy in "${gear_files_to_copy[@]}"; do
            if [ -f "$gear_file_to_copy" ]; then
                backup_message_printed=true
                break
            fi
        done

        if [ "$backup_message_printed" == true ]; then
            echo ""
            printGreen "Копіюємо бекап файли ноди Gear в папку /root/BACKUPNODES/Gear backup" && sleep 1
            mkdir -p "$gear_backup_dir"
            for gear_file_to_copy in "${gear_files_to_copy[@]}"; do
                if [ -f "$gear_file_to_copy" ]; then
                    echo "Збережено: $gear_file_to_copy" && sleep 1
                    cp "$gear_file_to_copy" "$gear_backup_dir/"
                fi
            done
        fi

        backup_message_printed=false

        for subspace_file_to_copy in "${subspace_files_to_copy[@]}"; do
            if [ -f "$subspace_file_to_copy" ]; then
                backup_message_printed=true
                break
            fi
        done

        if [ "$backup_message_printed" == true ]; then
            echo ""
            printGreen "Копіюємо бекап файли ноди Subspace в папку /root/BACKUPNODES/Subspace backup" && sleep 1
            mkdir -p "$subspace_backup_dir"
            for subspace_file_to_copy in "${subspace_files_to_copy[@]}"; do
                if [ -f "$subspace_file_to_copy" ]; then
                    echo "Збережено: $subspace_file_to_copy" && sleep 1
                    cp "$subspace_file_to_copy" "$subspace_backup_dir/"
                fi
            done
        fi

        backup_message_printed=false

        for nibiru_file_to_copy in "${nibiru_files_to_copy[@]}"; do
            if [ -f "$nibiru_source_dir/$nibiru_file_to_copy" ]; then
                backup_message_printed=true
                break
            fi
        done

        if [ "$backup_message_printed" == true ]; then
            echo ""
            printGreen "Копіюємо бекап файли ноди Nibiru в папку $nibiru_backup_dir" && sleep 1
            mkdir -p "$nibiru_backup_dir"
            for nibiru_file_to_copy in "${nibiru_files_to_copy[@]}"; do
                if [ -f "$nibiru_source_dir/$nibiru_file_to_copy" ]; then
                    echo "Збережено: $nibiru_file_to_copy" && sleep 1
                    cp "$nibiru_source_dir/$nibiru_file_to_copy" "$nibiru_backup_dir/"
                fi
            done
        fi

        if [ "$backup_message_printed" == false ]; then
            printGreen "Процес бекапу нод відмінено."
        else
            echo ""
            printGreen "Backup завершено, перейдіть до основної директорії /root/BACKUPNODES та скопіюйте цю папку в безпечне місце собі на ПК."
            echo ""
            echo "Нижче вказано шлях до директорій, куди потрібно переносити ваші backup файли в залежності від ноди."
            printGreen "Lava:"
            echo "/root/.lava/data/priv_validator_state.json"
            echo "/root/.lava/config/node_key.json"
            echo "/root/.lava/config/priv_validator_key.json"
            echo ""
            printGreen "Gear:"
            echo "/root/.local/share/gear/chains/gear_staging_testnet_v7/network/"
            echo ""
            printGreen "Subspace:"
            echo "/root/.local/share/pulsar/node/chains/subspace_gemini_3f/network/"
            echo ""
            printGreen "Nibiru:"
            echo "/root/.nibid/data/priv_validator_state.json"
            echo "/root/.nibid/config/node_key.json"
            echo "/root/.nibid/config/priv_validator_key.json"
            echo ""
        fi
    else
        printGreen "Процес backup нод відмінено."
    fi
}

backup
