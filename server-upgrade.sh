#!/bin/bash

# Створюємо .bash_profile, якщо не існує
if [ ! -f "$HOME/.bash_profile" ]; then
  touch "$HOME/.bash_profile"
  echo "Created .bash_profile"
fi

# Оновлення та встановлення screen
sudo apt update
sudo apt install -y screen

# Повідомлення користувачу
echo -e "\e[32mПодальші оновлення відбудуться в сесії 'upgrade'.\e[0m"
echo -e "\e[32mПереглянути список сесій ви можете командою 'screen -ls'.\e[0m"
echo -e "\e[32mПідключитись до сесії оновлення можна командою 'screen -r upgrade'.\e[0m"
echo -e "\e[32mВи можете увійти в сесію, закрити сервер, або ж відключитись саме від сесії комбінацією Ctrl + A + D, і продовжити роботу на сервері, але рекомендується дочекатись повного оновлення серверу.\e[0m"

# Запускаємо screen сесію для оновлення та встановлення пакетів
screen -dmS upgrade bash -c "
  # Оновлення системи
  sudo apt update && sudo apt upgrade -y

  # Встановлення основних пакетів
  sudo apt install -y lz4 jq make git gcc build-essential curl chrony unzip gzip snapd tmux bc asic2 ufw htop net-tools ncdu nodejs ca-certificates zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev wget pkg-config lsb-release libssl-dev libreadline-dev libffi-dev screen

  # Встановлення Python
  sudo apt install -y python3 python3-pip
  python3 --version
  pip3 --version
  sudo apt install -y pip
  echo 'requests==2.25.1
  flask==1.1.2
  numpy==1.19.5
  pandas==1.2.4
  dnspython
  psutil
  tcp-latency' > requirements.txt
  pip install -r requirements.txt

  # Встановлення Docker
 curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  
  sudo apt-get update
  sudo apt-get install docker-ce docker-ce-cli containerd.io
  docker version

  # Встановлення Docker Compose
 VER=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)

curl -L "https://github.com/docker/compose/releases/download/"$VER"/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose
docker-compose --version

  # Встановлення Rust
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source \$HOME/.cargo/env
  rustup default stable
  rustup update
  rustup update nightly
  rustup target add wasm32-unknown-unknown --toolchain nightly

  # Встановлення Go
  sudo rm -rf /usr/local/go
  curl -L https://go.dev/dl/go1.21.6.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
  echo 'export PATH=\$PATH:/usr/local/go/bin:\$HOME/go/bin' >> \$HOME/.bash_profile
  source \$HOME/.bash_profile
  go install github.com/charmbracelet/gum@latest

  # Встановлення Node Version Manager (nvm)
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
  source ~/.bashrc
  nvm install --lts

  # Встановлення CPI.NODE Manager
  wget -qO- https://github.com/CPITMschool/Scripts/releases/download/v.1.0.0/cpinodes_manager.xz | xz -d | tar --strip-components=1 -C /root/ -xvf - && chmod +x /root/cpinodes && sudo rm -f /usr/local/bin/cpinodes && sudo ln -s /root/cpinodes /usr/local/bin/cpinodes

  # Встановлення LXC + LXD
  sudo apt install -y lxc lxc-utils lxc-templates lxd lxd-client bridge-utils

  # Додавання користувача до групи LXD
  sudo usermod -aG lxd \$USER
  newgrp lxd

  # Ініціалізація LXD (необхідно буде налаштувати вручну)
  sudo lxd init --auto

  # Встановлення необхідних мережевих інструментів для LXC
  sudo apt install -y iproute2 dnsutils iputils-ping iftop iotop vnstat

  # Встановлення корисних редакторів
  sudo apt install -y nano vim cat
  sudo apt install -y fail2ban


  # Перевірка наявності speedtest-cli, встановлення та виконання тесту швидкості інтернету
  if ! command -v speedtest-cli &> /dev/null; then
      sudo apt-get update
      sudo apt-get install -y speedtest-cli
  fi

  echo 'Усі пакети встановлені та налаштовані. Сервер готовий до роботи!'
"

echo "Всі команди запущені у новій screen сесії з ім'ям 'upgrade'."
