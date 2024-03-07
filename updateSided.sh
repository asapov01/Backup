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
  printGreen "На данний момент немає актуальних оновлень"


  


  printDelimiter
  printGreen "Переглянути журнал логів:         sudo journalctl -u sided -f -o cat"
  printGreen "Переглянути версію ноди:          sided version"
  printDelimiter
}

install
