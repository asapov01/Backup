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
    read -p "Введіть ім'я ноди (Lava, Nibiru, Gear, Subspace, Zetachain, Dymension, Babylon): " node_name
    case "$node_name" in
        Lava)
            lava_source_dir="/root/.lava/"
            lava_files_to_copy=("config/priv_validator_key.json" "config/node_key.json" "data/priv_validator_state.json")
            backup_node "$node_name" "$lava_source_dir" "${lava_files_to_copy[@]}"
            ;;
        Nibiru)
            nibiru_source_dir="/root/.nibid/"
            nibiru_files_to_copy=("config/priv_validator_key.json" "config/node_key.json" "data/priv_validator_state.json")
            backup_node "$node_name" "$nibiru_source_dir" "${nibiru_files_to_copy[@]}"
            ;;
        Gear)
            gear_source_dir="/root/.local/share/gear/chains/gear_staging_testnet_v7/network/"
            gear_files_to_copy=("secret_ed25519")
            backup_node "$node_name" "$gear_source_dir" "${gear_files_to_copy[@]}"
            ;;
        Subspace)
            subspace_source_dir="/root/.local/share/pulsar/node/chains/subspace_gemini_3g/network/"
            subspace_files_to_copy=("secret_ed25519")
            backup_node "$node_name" "$subspace_source_dir" "${subspace_files_to_copy[@]}"
            ;;
        Zetachain)
            zetacore_source_dir="/root/.zetacored/"
            zetacore_files_to_copy=("config/priv_validator_key.json" "config/node_key.json" "data/priv_validator_state.json")
            backup_node "$node_name" "$zetacore_source_dir" "${zetacore_files_to_copy[@]}"
            ;;
        Dymension)
            dymension_source_dir="$HOME/.dymension/"
            dymension_files_to_copy=("config/priv_validator_key.json" "data/priv_validator_state.json")
            backup_node "$node_name" "$dymension_source_dir" "${dymension_files_to_copy[@]}"
            ;;
        Babylon)
            babylon_source_dir="$HOME/.babylond/"
            babylon_files_to_copy=("config/priv_validator_key.json" "data/priv_validator_state.json")
            backup_node "$node_name" "$babylon_source_dir" "${babylon_files_to_copy[@]}"
            ;;
        *)
            echo "Некоректне ім'я ноди."
            ;;
    esac
}

function move_backup_files() {
    read -p "Введіть назву ноди (Lava, Nibiru, Gear, Subspace, Zetachain, Dymension, Babylon): " node_name
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
            # ... (аналогічно інші ноди)
            ;;
        Gear)
            # ... (аналогічно інші ноди)
            ;;
        Subspace)
            # ... (аналогічно інші ноди)
            ;;
        Zetachain)
            # ... (аналогічно інші ноди)
            ;;
        Dymension)
            # ... (аналогічно інші ноди)
            ;;
        Babylon)
            babylon_source_dir="$HOME/.babylond/"
            cp "/root/BACKUPNODES/Babylon backup/priv_validator_state.json" "$babylon_source_dir/data/"
            cp "/root/BACKUPNODES/Babylon backup/priv_validator_key.json" "$babylon_source_dir/config/"
            systemctl restart babylond
            echo -e "\e[1m\e[32mБекап файли Babylon перенесено\e[0m" && sleep 1
            echo -e "\e[1m\e[32mВам залишилось тільки відновити ваш гаманець за допомогою мнемонічної фрази, командою: babylond keys add wallet --recover\e[0m"
            ;;
        *)
            echo "Некоректне ім'я ноди."
            ;;
    esac
}

function view_backup_paths() {
    # ... (аналогічно інші ноди)
}

function main_menu() {
    while true; do
        clear
        logo
        echo -e "\e[1m\e[32mВиберіть потрібний вам пункт:\e[0m"
        echo "1 - Backup нод Lava, Nibiru, Gear, Subspace, Zetachain, Dymension, Babylon (виконується лише для встановленних на сервері, зберігаються в папку /root/BACKUPNODES)"
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
