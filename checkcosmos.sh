User
#!/bin/bash


printGreen() {
  echo -e "\e[32m$1\e[0m"
}

function printDelimiter {
  echo "==========================================="
}


checkNode() {
  node_name=$1
  node_command=$2
  echo ""
  printDelimiter
  printGreen "Журнал логів ноди: $node_name"
  printDelimiter
  echo ""

  
  timeout 5 sudo journalctl -u $node_command -f -o cat
}


checkNode "Lava" "lavad"

checkNode "Zetachain" "zetacored"

checkNode "Babylond" "babylond"

checkNode "Dymension" "dymd"

echo ""
