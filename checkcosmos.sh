#!/bin/bash

# Функція для перевірки ноди
check_node() {
  local service_name=$1
  local dir_name=$2
  local rpc_url=$3
  local log_command=$4
  local custom_dir=$5

  echo "Checking ${service_name} node..."

  # Перевірка чи є процес ноди
  if ! pgrep -x "$service_name" > /dev/null; then
    echo -e "\e[31mNode ${service_name} is not installed or not running.\e[0m"
    return
  fi

  # Перевірка розміру директорії ноди
  if [ "$custom_dir" = true ]; then
    echo "Node directory size:"
    du -sh "$dir_name"
  else
    echo "Node directory size:"
    du -sh "$HOME/.${dir_name}"
  fi

  # Перевірка використання пам'яті процесом ноди
  ps -p $(pgrep $service_name) -o rss= | awk '{printf("The process uses memory: %.2f MB\n", $1/1024)}'

  # Перевірка висоти блоків, якщо надано URL для RPC
  if [ -n "$rpc_url" ]; then
    local_height=$($service_name status | jq -r .sync_info.latest_block_height)
    network_height=$(curl -s $rpc_url | jq -r .result.sync_info.latest_block_height)
    blocks_left=$((network_height - local_height))
    echo "Your node height: $local_height"
    echo "Network height: $network_height"
    echo "Blocks left: $blocks_left"
  fi

  # Перевірка журналу логів
  echo "Checking logs for ${service_name}..."
  if [ -n "$log_command" ]; then
    eval "$log_command" &
    sleep 5
    pkill -P $!
  else
    sudo journalctl -u $service_name -f -o cat &
    sleep 5
    pkill -P $!
  fi

  echo "---------------------------------------------"
}

# Перевірка всіх нод
check_node "lavad" "lava" "https://rpc.lava-testnet.unitynodes.com/status"
check_node "wardend" "warden" "https://rpc.warden-testnet.unitynodes.com/status"
check_node "initiad" "initia" "https://rpc.initia.unitynodes.com/status"
check_node "0gchaind" "0gchain" "https://rpc.0gchain-testnet.unitynodes.com/status"
check_node "zgs" "$HOME/0g-storage-node" "" "tail -f $HOME/0g-storage-node/run/log/*" true
check_node "sided" "side" "https://rpc.side-testnet.unitynodes.com/status"
