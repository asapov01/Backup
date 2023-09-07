#!/bin/bash

function logo() {
    bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function printGreen {
    echo -e "\e[1m\e[32m${1}\e[0m"
}

clear
logo

printGreen "Бажаєте зробити backup нод: Lava,Nibiru,Subspace,Gear? (Y/N)"
read response

function backup() {
    if [[ $response == "Y" || $response == "y" ]]; then
        backup_dir="/root/BACKUPNODES"
        mkdir -p "$backup_dir"

        lava_backup_dir="$backup_dir/Lava backup"
        mkdir -p "$lava_backup_dir"

        cp "/root/.lava/config/priv_validator_key.json" "$lava_backup_dir/"
        cp "/root/.lava/config/node_key.json" "$lava_backup_dir/"
        cp "/root/.lava/data/priv_validator_state.json" "$lava_backup_dir/"
        echo ""
        printGreen "Файли ноди Lava скопійовано в папку /root/BACKUPNODES/Lava backup" && sleep 2

        gear_backup_dir="$backup_dir/Gear backup"
        mkdir -p "$gear_backup_dir"

        gear_source_dir="/root/.local/share/gear/chains/gear_staging_testnet_v7/network/" 
        gear_files_to_copy=( "$gear_source_dir/secret_ed"* )
        for gear_file_to_copy in "${gear_files_to_copy[@]}"; do
            if [ -f "$gear_file_to_copy" ]; then
                cp "$gear_file_to_copy" "$gear_backup_dir/"
                echo ""
                printGreen "Файли ноди Gear скопійовано в папку /root/BACKUPNODES/Gear backup" && sleep 2
            fi
        done

        subspace_backup_dir="$backup_dir/Subspace backup"
        mkdir -p "$subspace_backup_dir"

        subspace_source_dir="/root/.local/share/pulsar/node/chains/subspace_gemini_3f/network/"
        subspace_files_to_copy=( "$subspace_source_dir/secret_ed"* )
        for subspace_file_to_copy in "${subspace_files_to_copy[@]}"; do
            if [ -f "$subspace_file_to_copy" ]; then
                cp "$subspace_file_to_copy" "$subspace_backup_dir/"
                echo ""
                printGreen "Бекап файли ноди Subspace скопійовано в папку /root/BACKUPNODES/Subspace backup" && sleep 2
            fi
        done

        nibiru_backup_dir="$backup_dir/Nibiru backup"
        mkdir -p "$nibiru_backup_dir"

        cp "/root/.nibid/config/priv_validator_key.json" "$nibiru_backup_dir/"
        cp "/root/.nibid/config/node_key.json" "$nibiru_backup_dir/"
        cp "/root/.nibid/data/priv_validator_state.json" "$nibiru_backup_dir/"
        echo ""
        printGreen "Файли ноди Nibiru скопійовано в папку /root/BACKUPNODES/Nibiru backup" && sleep 2
        echo ""
        echo "Backup завершено, перейдіть до основної директорії /root/BACKUPNODES та скопіюйте цю папку в безпечне місце собі на ПК."
        echo ""
        echo "Нижче вказано шлях до директорій, куди потрібно перенести ваші backup файли на новий сервер. В залежності від вашої ноди."
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
    else
        printGreen "Процес backup нод відмінено."
    fi
}

backup
