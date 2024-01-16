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
    backup_dir="$HOME/BACKUPNODES/${node_name} backup"

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
            lava_source_dir="$HOME/.lava/"
            lava_files_to_copy=("config/priv_validator_key.json" "config/node_key.json" "data/priv_validator_state.json")
            backup_node "$node_name" "$lava_source_dir" "${lava_files_to_copy[@]}"
            echo ""
            printGreen "Ваш приватний ключ ноди Lava в тектосовому форматі, запишіть собі в безпечне місце:"
            cat $HOME/.lava/config/priv_validator_key.json
            echo ""
            ;;
        Nibiru)
            nibiru_source_dir="$HOME/.nibid/"
            nibiru_files_to_copy=("config/priv_validator_key.json" "config/node_key.json" "data/priv_validator_state.json")
            backup_node "$node_name" "$nibiru_source_dir" "${nibiru_files_to_copy[@]}"
            printGreen "Ваш приватний ключ ноди Nibiru в тектосовому форматі, запишіть собі в безпечне місце:"
            cat $HOME/.nibid/config/priv_validator_key.json
            echo ""
            ;;
        Gear)
            gear_source_dir="$HOME/.local/share/gear/chains/gear_staging_testnet_v7/network/"
            gear_files_to_copy=("secret_ed25519")
            backup_node "$node_name" "$gear_source_dir" "${gear_files_to_copy[@]}"
            ;;
        Subspace)
            subspace_source_dir="$HOME/.local/share/pulsar/node/chains/subspace_gemini_3g/network/"
            subspace_files_to_copy=("secret_ed25519")
            backup_node "$node_name" "$subspace_source_dir" "${subspace_files_to_copy[@]}"
            ;;
        Zetachain)
            zetacore_source_dir="$HOME/.zetacored/"
            zetacore_files_to_copy=("config/priv_validator_key.json" "config/node_key.json" "data/priv_validator_state.json")
            backup_node "$node_name" "$zetacore_source_dir" "${zetacore_files_to_copy[@]}"
            printGreen "Ваш приватний ключ ноди Zetachain в тектосовому форматі, запишіть собі в безпечне місце:"
            cat $HOME/.zetacored/config/priv_validator_key.json
            echo ""
            ;;
        Dymension)
            dymension_source_dir="$HOME/.dymension"
            dymension_files_to_copy=("config/priv_validator_key.json" "data/priv_validator_state.json")
            backup_node "$node_name" "$dymension_source_dir" "${dymension_files_to_copy[@]}"
            printGreen "Ваш приватний ключ ноди Dymension в тектосовому форматі, запишіть собі в безпечне місце:"
            cat $HOME/.dymension/config/priv_validator_key.json
            echo ""
            ;;
        Babylon)
            babylon_source_dir="$HOME/.babylond"
            babylon_files_to_copy=("config/priv_validator_key.json" "data/priv_validator_state.json")
            backup_node "$node_name" "$babylon_source_dir" "${babylon_files_to_copy[@]}"
            printGreen "Ваш приватний ключ ноди Babylon в тектосовому форматі, запишіть собі в безпечне місце:"
            cat $HOME/.babylond/config/priv_validator_key.json
            echo ""

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
            cp "$HOME/BACKUPNODES/Lava backup/priv_validator_state.json" "$HOME/.lava/data/"
            cp "$HOME/BACKUPNODES/Lava backup/node_key.json" "$HOME/.lava/config/"
            cp "$HOME/BACKUPNODES/Lava backup/priv_validator_key.json" "$HOME/.lava/config/"
            systemctl restart lavad
            echo -e "\e[1m\e[32mБекап файли Lava перенесено\e[0m" && sleep 1
            echo -e "\e[1m\e[32mВам залишилось тільки відновити ваш гаманець за допомогою мнемонічної фрази, командою: lavad keys add wallet --recover\e[0m"
            echo ""
            printGreen "Ваш приватний ключ ноди Lava в тектосовому форматі, порівняйте з вашим оригінальним початковим ключем:"
            cat $HOME/.lava/config/priv_validator_key.json
            echo ""
            ;;
        Nibiru)
            nibiru_source_dir="$HOME/.nibid/"
            cp "$HOME/BACKUPNODES/Nibiru backup/priv_validator_state.json" "$nibiru_source_dir/data/"
            cp "$HOME/BACKUPNODES/Nibiru backup/node_key.json" "$nibiru_source_dir/config/"
            cp "$HOME/BACKUPNODES/Nibiru backup/priv_validator_key.json" "$nibiru_source_dir/config/"
            systemctl restart nibid
            echo -e "\e[1m\e[32mБекап файли Nibiru перенесено\e[0m" && sleep 1
            echo -e "\e[1m\e[32mВам залишилось тільки відновити ваш гаманець за допомогою мнемонічної фрази, командою: nibid keys add wallet --recover\e[0m"
             echo ""
            printGreen "Ваш приватний ключ ноди Nibiru в тектосовому форматі, порівняйте з вашим оригінальним початковим ключем:"
            cat $HOME/.nibid/config/priv_validator_key.json
            echo ""
            ;;
        Gear)
            gear_source_dir="$HOME/.local/share/gear/chains/gear_staging_testnet_v7/network/"
            cp "$HOME/BACKUPNODES/Gear backup/secret_ed25519" "$gear_source_dir"
            systemctl restart gear
            echo -e "\e[1m\e[32mБекап файли Gear перенесено\e[0m"
            ;;
        Subspace)
            subspace_source_dir="$HOME/.local/share/pulsar/node/chains/subspace_gemini_3g/network/"
            cp "$HOME/BACKUPNODES/Subspace backup/secret_ed25519" "$subspace_source_dir"
            echo -e "\e[1m\e[32mБекап файли Subspace перенесено\e[0m" && sleep 1
            ;;
        Zetachain)
            zetacore_source_dir="$HOME/.zetacored/"
            cp "$HOME/BACKUPNODES/Zetachain backup/priv_validator_state.json" "$zetacore_source_dir/data/"
            cp "$HOME/BACKUPNODES/Zetachain backup/node_key.json" "$zetacore_source_dir/config/"
            cp "$HOME/BACKUPNODES/Zetachain backup/priv_validator_key.json" "$zetacore_source_dir/config/"
            systemctl restart zetacored
            echo -e "\e[1m\e[32mБекап файли Zetachain перенесено\e[0m" && sleep 1
            echo -e "\e[1m\e[32mВам залишилось тільки відновити ваш гаманець за допомогою мнемонічної фрази, командою: zetacored keys add wallet --recover\e[0m"
            echo ""
            printGreen "Ваш приватний ключ ноди Zetachain в тектосовому форматі, порівняйте з вашим оригінальним початковим ключем:"
            cat $HOME/.zetacored/config/priv_validator_key.json
            echo ""
            ;;
        Dymension)
            dymension_source_dir="$HOME/.dymension"
            cp "$HOME/BACKUPNODES/Dymension backup/priv_validator_state.json" "$dymension_source_dir/data/"
            cp "$HOME/BACKUPNODES/Dymension backup/node_key.json" "$dymension_source_dir/config/"
            systemctl restart dymd.service
            echo -e "\e[1m\e[32mБекап файли Dymension перенесено\e[0m" && sleep 1
            echo -e "\e[1m\e[32mВам залишилось тільки відновити ваш гаманець за допомогою мнемонічної фрази, командою: dymensiond keys add wallet --recover\e[0m"
            echo ""
            printGreen "Ваш приватний ключ ноди Dymension в тектосовому форматі, порівняйте з вашим оригінальним початковим ключем:"
            cat $HOME/.dymension/config/priv_validator_key.json
            echo ""
            ;;
        Babylon)
            babylon_source_dir="$HOME/.babylond/"
            cp "$HOME/BACKUPNODES/Babylon backup/priv_validator_state.json" "$babylon_source_dir/data/"
            cp "$HOME/BACKUPNODES/Babylon backup/priv_validator_key.json" "$babylon_source_dir/config/"
            systemctl restart babylond
            echo -e "\e[1m\e[32mБекап файли Babylon перенесено\e[0m" && sleep 1
            echo -e "\e[1m\e[32mВам залишилось тільки відновити ваш гаманець за допомогою мнемонічної фрази, командою: babylond keys add wallet --recover\e[0m"
            echo ""
            printGreen "Ваш приватний ключ ноди Babylon в тектосовому форматі, порівняйте з вашим оригінальним початковим ключем:"
            cat $HOME/.babylond/config/priv_validator_key.json
            echo ""
            ;;
        *)
            echo "Некоректне ім'я ноди."
            ;;
    esac
}


function view_backup_paths() {
    echo -e "\e[1m\e[32mBackup завершено, перейдіть до основної директорії $HOME/BACKUPNODES та скопіюйте цю папку в безпечне місце собі на ПК.\e[0m"
    echo -e "\e[1m\e[32mНижче вказано шлях до директорій, куди потрібно переносити ваші backup файли в залежності від ноди.\e[0m"
    case "$node_name" in
        Lava)
            echo -e "\e[1m\e[32mLava:\e[0m"
            echo "$HOME/.lava/data/priv_validator_state.json"
            echo "$HOME/.lava/config/node_key.json"
            echo "$HOME/.lava/config/priv_validator_key.json"
            ;;
        Nibiru)
            echo -e "\e[1m\e[32mNibiru:\e[0m"
            echo "$HOME/.nibid/data/priv_validator_state.json"
            echo "$HOME/.nibid/config/node_key.json"
            echo "$HOME/.nibid/config/priv_validator_key.json"
            ;;
        Gear)
            echo -e "\e[1m\e[32mGear:\e[0m"
            echo "$HOME/.local/share/gear/chains/gear_staging_testnet_v7/network/"
            ;;
        Subspace)
            echo -e "\e[1m\e[32mSubspace:\e[0m"
            echo "$HOME/.local/share/pulsar/node/chains/subspace_gemini_3g/network/"
            ;;
        Zetachain)
            echo -e "\e[1m\e[32mZetachain:\e[0m"
            echo "$HOME/.zetacored/data/priv_validator_state.json"
            echo "$HOME/.zetacored/config/node_key.json"
            echo "$HOME/.zetacored/config/priv_validator.json"
            ;;
        Dymension)
            echo -e "\e[1m\e[32mDymension:\e[0m"
            echo "$HOME/.dymension/data/priv_validator_state.json"
            echo "$HOME/.dymension/config/priv_validator_key.json"
            ;;
        Babylon)
            echo -e "\e[1m\e[32mBabylon:\e[0m"
            echo "$HOME/.babylond/data/priv_validator_state.json"
            echo "$HOME/.babylond/config/priv_validator_key.json"
            ;;
        *)
            echo "Некоректне ім'я ноди."
            ;;
    esac
}


function main_menu() {
    while true; do
        clear
        logo
        echo -e "\e[1m\e[32mВиберіть потрібний вам пункт:\e[0m"
        echo "1 - Backup нод Lava, Nibiru, Gear, Subspace, Zetachain, Dymension, Babylon (виконується лише для встановленних на сервері, зберігаються в папку $HOME/BACKUPNODES)"
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
