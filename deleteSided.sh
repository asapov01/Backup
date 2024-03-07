#!/bin/bash

function printGreen {
  echo -e "\e[1m\e[32m${1}\e[0m"
}

function logo() {
  bash <(curl -s https://raw.githubusercontent.com/CPITMschool/Scripts/main/logo.sh)
}

function delete() {
  sudo systemctl stop sided.service
  sudo systemctl disable sided
  sudo rm -rf $HOME/.side
  sudo rm -rf $HOME/.sidechain
  sudo rm -rf $HOME/side
  sudo rm -rf $HOME/sidechain
  sudo rm -rf /etc/systemd/system/sided.service
  sudo rm -rf /usr/local/bin/sided
  sudo systemctl daemon-reload
}

logo
delete

printGreen "Side Protocol node видалено"
