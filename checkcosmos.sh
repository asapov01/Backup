#!/bin/bash

# Функція для перевірки ноди
check_node_info() {
  local service_name=$1
  local dir_name=$2
  local rpc_url=$3
  local custom_dir=$4

  echo -e "\e[32mChecking \e[33m${service_name}\e[32m node...\e[0m"

  # Перевірка чи є процес ноди
  if ! pgrep -x "$service_name" > /dev/null; then
    echo -e "\e[31mNode ${service_name} is not installed or not running.\e[0m"
    echo ""
    echo "---------------------------------------------"
    echo ""
    return
  fi

  # Перевірка розміру директорії ноди
  if [ "$custom_dir" = true ]; then
    echo -e "\e[32mNode directory size:\e[0m"
    du -sh "$dir_name"
  else
    echo -e "\e[32mNode directory size:\e[0m"
    du -sh "$HOME/.${dir_name}"
  fi

  # Перевірка використання пам'яті процесом ноди
  ps -p $(pgrep $service_name) -o rss= | awk '{printf("The process uses memory: %.2f MB\n", $1/1024)}'

  # Перевірка висоти блоків, якщо надано URL для RPC
  if [ -n "$rpc_url" ]; then
    local_height=$($service_name status | jq -r .sync_info.latest_block_height)
    network_height=$(curl -s $rpc_url | jq -r .result.sync_info.latest_block_height)
    blocks_left=$((network_height - local_height))

    echo -e "\e[32mYour node height:\e[0m"
    echo -e "\e[31m$local_height\e[0m"
    echo -e "\e[32mNetwork height:\e[0m"
    echo -e "\e[31m$network_height\e[0m"
    echo -e "\e[32mBlocks left:\e[0m"
    if [ $blocks_left -ge 0 ]; then
      echo -e "\e[31m$blocks_left\e[0m"
    else
      echo -e "\e[32m$blocks_left\e[0m"
    fi
  fi

  echo ""
  echo "---------------------------------------------"
  echo ""
}

# Функція для перевірки журналу логів
check_node_logs() {
  local service_name=$1
  local log_command=$2

  echo -e "\e[32mChecking logs for \e[33m${service_name}\e[32m...\e[0m"

  # Перевірка чи є процес ноди
  if ! pgrep -x "$service_name" > /dev/null; then
    echo -e "\e[31mNode ${service_name} is not installed or not running. Skipping log check.\e[0m"
    echo ""
    echo "---------------------------------------------"
    echo ""
    return
  fi

  if [ -n "$log_command" ]; then
    eval "$log_command | tail -n 25"
  else
    sudo journalctl -u $service_name -n 25 --output cat --no-pager
  fi

  echo ""
  echo "---------------------------------------------"
  echo ""

  # Закриття інтерактивного режиму
  sleep 1
}

# Перевірка логів для всіх нод
check_node_logs "lavad" ""
check_node_logs "wardend" ""
check_node_logs "initiad" ""
check_node_logs "0gchaind" ""
check_node_logs "tail -n 25 $HOME/0g-storage-node/run/log/zgs.log.$(TZ=UTC date +%Y-%m-%d)"
check_node_logs "sided" ""

# Перевірка всіх нод
check_node_info "lavad" "lava" "https://rpc.lava-testnet.unitynodes.com/status" false
check_node_info "wardend" "warden" "https://rpc.warden-testnet.unitynodes.com/status" false
check_node_info "initiad" "initia" "https://rpc.initia.unitynodes.com/status" false
check_node_info "0gchaind" "0gchain" "https://rpc.0gchain-testnet.unitynodes.com/status" false
check_node_info "zgs" "$HOME/0g-storage-node" "" true
check_node_info "sided" "side" "https://rpc.side-testnet.unitynodes.com/status" false
