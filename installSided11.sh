#!/bin/bash

function printDelimiter {
  echo "==========================================="
}

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

function install() {
  clear
  source <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)

  read -p "Введіть ім'я moniker (наприклад, Oliver):" MONIKER
  echo 'export MONIKER='$MONIKER
  PORT="${PORT:-22}"
  echo "export PORT=$PORT"
  echo "export SIDE_CHAIN_ID="side-testnet-2"" >> $HOME/.bash_profile
  echo "export SIDE_PORT="$PORT"" >> $HOME/.bash_profile
  source $HOME/.bash_profile
  
  printGreen "Встановлення необхідних залежностей"
  sudo apt update
  sudo apt install curl git wget htop tmux build-essential jq make lz4 gcc unzip -y
  bash <(curl -s "https://raw.githubusercontent.com/nodejumper-org/cosmos-scripts/master/utils/go_install.sh")
  source $HOME/.bash_profile

  printGreen "Встановлення Side Protocol"
  cd $HOME
  rm -rf side
  git clone https://github.com/sideprotocol/side.git
  cd side
  git checkout v0.6.0
  make install

  sided config node tcp://localhost:${SIDE_PORT}657
  sided config keyring-backend os
  sided config chain-id side-testnet-2
  sided init "$MONIKER" --chain-id side-testnet-2

  wget -O $HOME/.side/config/genesis.json https://testnet-files.itrocket.net/side/genesis.json
  wget -O $HOME/.side/config/addrbook.json https://testnet-files.itrocket.net/side/addrbook.json

  SEEDS="9c14080752bdfa33f4624f83cd155e2d3976e303@side-testnet-seed.itrocket.net:45656"
  PEERS="bbbf623474e377664673bde3256fc35a36ba0df1@side-testnet-peer.itrocket.net:45656"
  sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.side/config/config.toml


  sed -i.bak -e "s%:1317%:${SIDE_PORT}317%g;
  s%:8080%:${SIDE_PORT}080%g;
  s%:9090%:${SIDE_PORT}090%g;
  s%:9091%:${SIDE_PORT}091%g;
  s%:8545%:${SIDE_PORT}545%g;
  s%:8546%:${SIDE_PORT}546%g;
  s%:6065%:${SIDE_PORT}065%g" $HOME/.side/config/app.toml
  
  

  sed -i.bak -e "s%:26658%:${SIDE_PORT}658%g;
  s%:26657%:${SIDE_PORT}657%g;
  s%:6060%:${SIDE_PORT}060%g;
  s%:26656%:${SIDE_PORT}656%g;
  s%^external_address = \"\"%external_address = \"$(wget -qO- eth0.me):${SIDE_PORT}656\"%;
  s%:26660%:${SIDE_PORT}660%g" $HOME/.side/config/config.toml
  
 
  sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.side/config/app.toml
  sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.side/config/app.toml
  sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"50\"/" $HOME/.side/config/app.toml
  
  
  sed -i 's|minimum-gas-prices =.*|minimum-gas-prices = "0.005uside"|g' $HOME/.side/config/app.toml
  sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.side/config/config.toml
  sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.side/config/config.toml
  sleep 1
  echo done
  
  
    sudo tee /etc/systemd/system/sided.service > /dev/null <<EOF
    [Unit]
    Description=side node
    After=network-online.target
    [Service]
    User=$USER
    WorkingDirectory=$HOME/.side
    ExecStart=$(which sided) start --home $HOME/.side
    Restart=on-failure
    RestartSec=5
    LimitNOFILE=65535
    [Install]
    WantedBy=multi-user.target
EOF


    printGreen "Завантажуємо снепшот та запускаємо ноду"
    sided tendermint unsafe-reset-all --home $HOME/.side
    curl https://testnet-files.itrocket.net/side/snap_side.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.side
    



  sudo systemctl daemon-reload
  sudo systemctl enable sided
  sudo systemctl restart sided && sudo journalctl -u sided -f

  printDelimiter
  printGreen "Переглянути журнал логів:         sudo journalctl -u sided -f -o cat"
  source $HOME/.bash_profile
  printDelimiter
}

install
