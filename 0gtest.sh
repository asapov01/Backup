#!/bin/bash

source <(curl -s https://raw.githubusercontent.com/UnityNodes/scripts/main/utils.sh)


clear
logo
printColor blue "Install, updat, package"
sudo apt update && sudo apt upgrade -y && sleep 1
sudo apt install curl tar wget clang pkg-config protobuf-compiler libssl-dev jq build-essential protobuf-compiler bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y && sleep 1
sudo apt -qy upgrade

printColor blue "Remove and install Go" && sleep 1
sudo rm -rf /usr/local/go
sudo rm /etc/paths.d/go
sudo apt-get remove golang-go
sudo apt-get remove --auto-remove golang-go
VER="1.22.0"
wget "https://golang.org/dl/go$VER.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$VER.linux-amd64.tar.gz"
rm "go$VER.linux-amd64.tar.gz"
[ ! -f ~/.bash_profile ] && touch ~/.bash_profile
echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin" >> ~/.bash_profile
source $HOME/.bash_profile
[ ! -d ~/go/bin ] && mkdir -p ~/go/bin


cd $HOME

printColor blue "Install, updat, package"
sudo apt update && sudo apt upgrade -y

printColor blue "Install rust" && sleep 1
sudo apt-get update
sudo apt install build-essential
sudo apt install --assume-yes git clang curl libssl-dev protobuf-compiler
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env
rustup default stable
rustup update
rustup update nightly
rustup target add wasm32-unknown-unknown --toolchain nightly


printColor blue "Install 0G Storage"
cd $HOME
git clone -b v0.3.0 https://github.com/0glabs/0g-storage-node.git
cd 0g-storage-node
git submodule update --init
cargo build --release
sudo cp $HOME/0g-storage-node/target/release/zgs_node /usr/local/bin
cd $HOME

0gchaind keys unsafe-export-eth-key wallet

printColor Yellow "if the node and wallet is created on this server you should see your private key"
printColor Red "Copy it for further installation"
printColor Yellow "if the node and wallet is created on another server, just use it in the subsequent installation"
read -p "Continue installation? (y/n): " choice
case "$choice" in
  y|Y ) 
    echo "Continuation..." & sleep 2
    ;;
  n|N ) 
    echo "Cancelled."
    exit 0
    ;;
  * ) 
    echo "Please enter 'y' or 'n'."
    exit 1
    ;;
esac

printColor blue "Node Configuration"
echo ""
echo 'export BLOCKCHAIN_RPC_ENDPOINT="http://evm-rpc.0gchain-testnet.unitynodes.com:8545"' >> ~/.bash_profile
config_file="/root/0g-storage-node/run/config.toml"
network_height=$(curl -s https://rpc.0gchain-testnet.unitynodes.com/status | jq -r '.result.sync_info.latest_block_height')
source ~/.bash_profile
sed -i '
s|# network_dir = "network"|network_dir = "network"|
s|# network_libp2p_port = 1234|network_libp2p_port = 1234|
s|# network_discovery_port = 1234|network_discovery_port = 1234|
s|# rpc_enabled = true|rpc_enabled = true|
s|# db_dir = "db"|db_dir = "db"|
s|# log_config_file = "log_config"|log_config_file = "log_config"|
s|# log_directory = "log"|log_directory = "log"|
s|^blockchain_rpc_endpoint = \".*|blockchain_rpc_endpoint = "'"$BLOCKCHAIN_RPC_ENDPOINT"'"|
' $HOME/0g-storage-node/run/config.toml
read -p "Your Private KEY: " PRIVATE_KEY
sed -i 's|^miner_key = ""|miner_key = "'"$PRIVATE_KEY"'"|' $HOME/0g-storage-node/run/config.toml
sed -i "s/^log_sync_start_block_number = .*/log_sync_start_block_number = $network_height/" $config_file


printColor blue "Create service file"

sudo tee /etc/systemd/system/zgs.service > /dev/null <<EOF
[Unit]
Description=0G Storage Node
After=network.target

[Service]
User=$USER
Type=simple
WorkingDirectory=$HOME/0g-storage-node/run
ExecStart=$HOME/0g-storage-node/target/release/zgs_node --config $HOME/0g-storage-node/run/config.toml
Restart=on-failure
RestartSec=10
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

printColor blue "Start 0G Storage Node"

sudo systemctl daemon-reload && \
sudo systemctl enable zgs && \
sudo systemctl restart zgs && \
sudo systemctl status zgs

echo ""
printLine
printColor blue "Check your logs        >>> tail -f 0g-storage-node/run/log/* "
printLine
printColor blue "Enjoy Unity Nodes      >>> https://unitynodes.com"
printColor blue "Our service            >>> https://services.unitynodes.com"
printColor blue "Our blog               >>> https://medium.com/@unitynodes"
printLine
