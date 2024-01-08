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
  
  printGreen "Moniker - назва вашого валідатора, яка буде використовуватись в подальшому"
  printGreen "Введіть moniker для вашої ноди(Наприклад:Asapov):"
  read -r NODE_MONIKER

  printGreen "Оновлення сервера та встановлення GO"
  sudo apt update
  sudo apt install -y curl git jq lz4 build-essential unzip

  bash <(curl -s "https://raw.githubusercontent.com/nodejumper-org/cosmos-scripts/master/utils/go_install.sh")
  source .bash_profile

  cd $HOME
  rm -rf babylon
  git clone https://github.com/babylonchain/babylon
  cd babylon
  git checkout v0.7.2

  make install

  babylond config chain-id bbn-test-2
  babylond config keyring-backend test
  babylond init $NODE_MONIKER --chain-id bbn-test-2

  curl -L https://snapshots-testnet.nodejumper.io/babylon-testnet/genesis.json > $HOME/.babylond/config/genesis.json
  curl -L https://snapshots-testnet.nodejumper.io/babylon-testnet/addrbook.json > $HOME/.babylond/config/addrbook.json

  
sed -i \
  -e 's|^seeds *=.*|seeds = ""|' \
  -e 's|^peers *=.*|peers = "03ce5e1b5be3c9a81517d415f65378943996c864@18.207.168.204:26656,a5fabac19c732bf7d814cf22e7ffc23113dc9606@34.238.169.221:26656,ade4d8bc8cbe014af6ebdf3cb7b1e9ad36f412c0@testnet-seeds.polkachu.com:20656"|' \
  $HOME/.babylond/config/config.toml


sed -i -e 's|^minimum-gas-prices *=.*|minimum-gas-prices = "0.001ubbn"|' $HOME/.babylond/config/app.toml


sed -i \
  -e 's|^pruning *=.*|pruning = "custom"|' \
  -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
  -e 's|^pruning-interval *=.*|pruning-interval = "17"|' \
  $HOME/.babylond/config/app.toml


sed -i 's|^network *=.*|network = "mainnet"|g' $HOME/.babylond/config/app.toml


curl "https://snapshots-testnet.nodejumper.io/babylon-testnet/babylon-testnet_latest.tar.lz4" | lz4 -dc - | tar -xf - -C "$HOME/.babylond"

#Change port #7
sed -i.bak -e "s%:1317%:2017%g; 
s%:8080%:8780%g;
s%:9090%:9790%g;
s%:9091%:9791%g;
s%:8545%:9245%g;
s%:8546%:9246%g;
s%:6065%:6765%g" $HOME/.babylond/config/app.toml
sed -i.bak -e "s%:26658%:33658%g;
s%:26657%:33657%g;
s%:6060%:6760%g;
s%tcp://0.0.0.0:26656%tcp://0.0.0.0:33656%g;
s%:26660%:33660%g" $HOME/.babylond/config/config.toml
sed -i.bak -e "s%:26657%:33657%g" $HOME/.babylond/config/client.toml


sudo tee /etc/systemd/system/babylond.service > /dev/null << EOF
[Unit]
Description=Babylon node service
After=network-online.target
[Service]
User=$USER
ExecStart=$(which babylond) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable babylond.service
source .bash_profile

printGreen "Запускаємо ноду"
sudo systemctl start babylond.service

printDelimiter
printGreen "Переглянути журнал логів:         sudo journalctl -u babylond -f -o cat"
printGreen "Переглянути статус синхронізації: babylond status 2>&1 | jq .SyncInfo"
echo -e "\e[1;32mВаша нода Babylon займає наступний набір портів(#7):\e[0m 2017,8780,9790,9791,9245,9246,6765,33658,33657,6760,33656,33660"
printGreen "Запишіть значення портів, для можливості подальшого підселення космос нод, та уникнення конфліктів пов'язаних з портами"
echo "alias port_babylon='echo -e \"\e[1;32mВаша нода займає наступний набір портів(#7):\e[0m 2017,8780,9790,9791,9245,9246,6765,33658,33657,6760,33656,33660\"'" >> ~/.bash_profile
printGreen "Також якщо вам колись буде потрібно, введіть в терміналі port_babylon та ви знову побачите інформацію про список зайнятих портів"
printDelimiter
source ~/.bash_profile
}

install
