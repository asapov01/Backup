#!/bin/bash

function logo() {
    bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function printGreen {
    echo -e "\e[1m\e[32m${1}\e[0m"
}

function printRed {
    echo -e "\e[1m\e[31m${1}\e[0m"
}

function backup_node() {
    node_name="$1"
    source_dir="$2"
    files_to_copy=("${@:3}")
    backup_dir="/root/BACKUPNODES/${node_name} backup"

    backup_message_printed=false

    for file_to_copy in "${files_to_copy[@]}"; do
        if [ -f "$source_dir/$file_to_copy" ]; then
            backup_message_printed=true
            break
        fi
    done

    if [ "$backup_message_printed" == true ]; then
        mkdir -p "$backup_dir"
        for file_to_copy in "${files_to_copy[@]}"; do
            if [ -f "$source_dir/$file_to_copy" ]; then
                cp "$source_dir/$file_to_copy" "$backup_dir/" || { printRed "Не вдалось перенести бекап файли ноди $node_name"; return; }
            fi
        done
        echo -e "\e[1m\e[32mБекап файли ноди $node_name перенесено\e[0m"
    else
        echo -e "\e[1m\e[31mНе знайдено файли для бекапу ноди $node_name або SSD переповнений\e[0m"
    fi
}

function backup() {
    lava_source_dir="/root/.lava/"
    lava_files_to_copy=("config/priv_validator_key.json" "config/node_key.json" "data/priv_validator_state.json")

    gear_source_dir="/root/.local/share/gear/chains/gear_staging_testnet_v7/network/"
    gear_files_to_copy=("secret_ed25519")  

    subspace_source_dir="/root/.local/share/pulsar/node/chains/subspace_gemini_3g/network/"
    subspace_files_to_copy=("secret_ed25519") 

    nibiru_source_dir="/root/.nibid/"
    nibiru_files_to_copy=("config/priv_validator_key.json" "config/node_key.json" "data/priv_validator_state.json")

    zetacore_source_dir="/root/.zetacored/"
    zetacore_files_to_copy=("config/priv_validator_key.json" "config/node_key.json" "data/priv_validator_state.json")

    backup_node "Lava" "$lava_source_dir" "${lava_files_to_copy[@]}"
    backup_node "Gear" "$gear_source_dir" "${gear_files_to_copy[@]}"
    backup_node "Subspace" "$subspace_source_dir" "${subspace_files_to_copy[@]}" 
    backup_node "Nibiru" "$nibiru_source_dir" "${nibiru_files_to_copy[@]}"
    backup_node "Zetachain" "$zetacore_source_dir" "${zetacore_files_to_copy[@]}"
}

function move_backup_files() {
    read -p "Введіть назву ноди (Lava, Nibiru, Gear, Subspace, Zetachain): " node_name
    case "$node_name" in
        Lava)
            cp "/root/BACKUPNODES/Lava backup/priv_validator_state.json" "/root/.lava/data/"  
            cp "/root/BACKUPNODES/Lava backup/node_key.json" "/root/.lava/config/"  
            cp "/root/BACKUPNODES/Lava backup/priv_validator_key.json" "/root/.lava/config/"  
            systemctl restart lavad
            echo -e "\e[1m\e[32mБекап файли Lava перенесено\e[0m" && sleep 1
            echo -e "\e[1m\e[32mВам залишилось тільки відновити ваш гаманець за допомогою мнемонічної фрази, командою: lavad keys add wallet --recover\e[0m"
            ;;
        Nibiru)
            cp "/root/BACKUPNODES/Nibiru backup/priv_validator_state.json" "/root/.nibid/data/"
            cp "/root/BACKUPNODES/Nibiru backup/node_key.json" "/root/.nibid/config/"
            cp "/root/BACKUPNODES/Nibiru backup/priv_validator_key.json" "/root/.nibid/config/"
            systemctl restart nibid
            echo -e "\e[1m\e[32mБекап файли Nibiru перенесено\e[0m" && sleep 1
            echo -e "\e[1m\e[32mВам залишилось тільки відновити ваш гаманець за допомогою мнемонічної фрази, командою: nibid keys add wallet --recover\e[0m"
            ;;
        Gear)
            cp "/root/BACKUPNODES/Gear backup/secret_ed25519" "/root/.local/share/gear/chains/gear_staging_testnet_v7/network/"
            systemctl restart gear
            echo -e "\e[1m\e[32mБекап файли Gear перенесено\e[0m"
            ;;
        Subspace)
            cp "/root/BACKUPNODES/Subspace backup/secret_ed25519" "/root/.local/share/subspace-node/chains/subspace_gemini_3g/network/"
            echo -e "\e[1m\e[32mБекап файли Subspace перенесено\e[0m" && sleep 1
            ;;
        Zetachain)
            cp "/root/BACKUPNODES/Zetachain backup/priv_validator_state.json" "/root/.zetacored/data/"
            cp "/root/BACKUPNODES/Zetachain backup/node_key.json" "/root/.zetacored/config/"
            cp "/root/BACKUPNODES/Zetachain backup/priv_validator.json" "/root/.zetacored/config/"
            systemctl restart zetacored
            echo -e "\e[1m\e[32mБекап файли Zetachain перенесено\e[0m" && sleep 1
            echo -e "\e[1m\e[32mВам залишилось тільки відновити ваш гаманець за допомогою мнемонічної фрази, командою: zetacored keys add wallet --recover\e[0m"
            ;;
        *)
            echo "Некоректне найменування ноди."
            ;;
    esac
}

function view_backup_paths() {
    echo -e "\e[1m\e[32mBackup завершено, перейдіть до основної директорії /root/BACKUPNODES та скопіюйте цю папку в безпечне місце собі на ПК.\e[0m"
    echo -e "\e[1m\e[32mНижче вказано шлях до директорій, куди потрібно переносити ваші backup файли в залежності від ноди.\e[0m"
    echo -e "\e[1m\e[32mLava:\e[0m"
    echo "/root/.lava/data/priv_validator_state.json"
    echo "/root/.lava/config/node_key.json"
    echo "/root/.lava/config/priv_validator_key.json"
    echo -e "\e[1m\e[32mGear:\e[0m"
    echo "/root/.local/share/gear/chains/gear_staging_testnet_v7/network/"
    echo -e "\e[1m\e[32mSubspace:\e[0m"
    echo "/root/.local/share/pulsar/node/chains/subspace_gemini_3g/network/"
    echo -e "\e[1m\e[32mNibiru:\e[0m"
    echo "/root/.nibid/data/priv_validator_state.json"
    echo "/root/.nibid/config/node_key.json"
    echo "/root/.nibid/config/priv_validator_key.json"
    echo -e "\e[1m\e[32mZetachain:\e[0m"
    echo "/root/.zetacored/data/priv_validator_state.json"
    echo "/root/.zetacored/config/node_key.json"
    echo "/root/.zetacored/config/priv_validator.json"
}

function main_menu() {
    while true; do
        clear
        logo
        echo -e "\e[1m\e[32mВиберіть потрібний вам пункт:\e[0m"
        echo "1 - Backup нод Lava, Nibiru, Gear, Subspace, Zetachain (виконується лише для встановленних на сервері, зберігаються в папку /root/BACKUPNODES)"
        echo "2 - Перемістити бекап файли ноди (для випадку якщо ви перевстановили/оновили ноду/видалили вузол)"
        echo "3 - Переглянути шляхи зберігання бекап файлів у нодах"
        echo "4 - Вийти з меню"
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
        read -p "Натисніть Enter, щоб повернутись до головного меню..."
    done
}

main_menu
