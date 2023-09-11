#!/bin/bash

function logo() {
    bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function printGreen {
    echo -e "\e[1m\e[32m${1}\e[0m"
}

function backup() {
    backup_dir="/root/BACKUPNODES"
    mkdir -p "$backup_dir"

    lava_source_dir="/root/.lava/"
    lava_files_to_copy=("config/priv_validator_key.json" "config/node_key.json" "data/priv_validator_state.json")
    lava_backup_dir="$backup_dir/Lava backup"

    gear_source_dir="/root/.local/share/gear/chains/gear_staging_testnet_v7/network/"
    gear_files_to_copy=("$gear_source_dir/secret_ed"*)
    gear_backup_dir="$backup_dir/Gear backup"

    subspace_source_dir="/root/.local/share/pulsar/node/chains/subspace_gemini_3f/network/"
    subspace_files_to_copy=("$subspace_source_dir/secret_ed"*)
    subspace_backup_dir="$backup_dir/Subspace backup"

    nibiru_source_dir="/root/.nibid/"
    nibiru_files_to_copy=("config/priv_validator_key.json" "config/node_key.json" "data/priv_validator_state.json")
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
}

function move_backup_files() {
    read -p "Введіть назву ноди (Lava, Nibiru, Gear, Subspace): " node_name
    case "$node_name" in
        Lava)
            cp "/root/BACKUPNODES/Lava backup/priv_validator_state.json" "/root/.lava/data/"
            cp "/root/BACKUPNODES/Lava backup/node_key.json" "/root/.lava/config/"
            cp "/root/BACKUPNODES/Lava backup/priv_validator_key.json" "/root/.lava/config/"
            systemctl restart lavad
            echo ""
            printGreen "Бекап файли Lava перенесено" && sleep 1
            ;;
        Nibiru)
            cp "/root/BACKUPNODES/Nibiru backup/priv_validator_state.json" "/root/.nibid/data/"
            cp "/root/BACKUPNODES/Nibiru backup/node_key.json" "/root/.nibid/config/"
            cp "/root/BACKUPNODES/Nibiru backup/priv_validator_key.json" "/root/.nibid/config/"
            systemctl restart nibid
            echo ""
            printGreen "Бекап файли Nibiru перенесено" && sleep 1
            ;;
        Gear)
            cp "/root/BACKUPNODES/Gear backup/secret_ed"* "/root/.local/share/gear/chains/gear_staging_testnet_v7/network/"
            systemctl restart gear
            echo ""
            printGreen "Бекап файли Gear перенесено" && sleep 1
            ;;
        Subspace)
            cp "/root/BACKUPNODES/Subspace backup/priv_validator_state.json" "/root/.local/share/gear/chains/gear_staging_testnet_v7/network/"
            echo ""
            printGreen "Бекап файли Subspace перенесено" && sleep 1
            ;;
        *)
            echo "Некоректне найменування ноди."
            ;;
    esac
}

function view_backup_paths() {
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
}

function main_menu() {
    while true; do
        clear
        logo
        echo ""
        printGreen "Виберіть потрібний вам пункт:"
        echo ""
        echo "1 - Backup нод Lava, Nibiru, Gear, Subspace (виконується лише для встановленних на сервері,зберігаються в папку /root/BACKUPNODES)"
        echo ""
        echo "2 - Перемістити бекап файли ноди (для випадку якщо ви перевстановили/оновили ноду/видалили вузол)"
        echo ""
        echo "3 - Переглянути шляхи зберігання бекап файлів у нодах"
        echo ""
        echo "4 - Вийти з меню"
        echo ""
        read -p "Ваш вибір: " choice
        case "$choice" in
            1)
                backup
                ;;
            2)
                move_backup_files
                ;;
            3)
                view_backup_paths
                ;;
            4)
                echo "Ви вийшли з меню."
                break
                ;;
            *)
                echo "Некоректний вибір. Спробуйте ще раз."
                ;;
        esac
        echo ""
        read -p "Натисніть Enter, щоб повернутись до головного меню..."
    done
}

main_menu
