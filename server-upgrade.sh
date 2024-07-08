#!/bin/bash

# Створюємо .bash_profile, якщо не існує
if [ ! -f "$HOME/.bash_profile" ]; then
  touch "$HOME/.bash_profile"
  echo "Created .bash_profile"
fi

# Оновлення та встановлення screen
sudo apt install -y screen

# Повідомлення користувачу
echo "Подальші оновлення відбудуться в сесії 'upgrade'."
echo "Переглянути список сесій ви можете командою 'screen -ls'."
echo "Підключитись до сесії оновлення можна командою 'screen -r upgrade'."
echo "Ви можете увійти в сесію, закрити сервер, або ж відключитись саме від сесії комбінацією Ctrl + A + D, і продовжити роботу на сервері, але рекомендується дочекатись повного оновлення серверу."

# Запускаємо screen сесію для оновлення та встановлення пакетів
screen -dmS upgrade bash -c "
  # Оновлення та оновлення системи
  sudo apt update && sudo apt upgrade -y

  # Встановлення основних пакетів
  sudo apt install -y lz4 jq make git gcc build-essential curl chrony unzip gzip snapd tmux bc asic2 ufw htop net-tools ncdu 
  sudo apt install -y ca-certificates zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev

  # Встановлення Python
  sudo apt install -y python3 python3-pip
  python3 --version
  pip3 --version

  # Встановлення Docker
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \$(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io
  docker version

  # Встановлення Docker Compose
  sudo apt-get install -y docker-compose
  docker-compose --version

  #Rust
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source $HOME/.cargo/env

# Оновлення Rust та встановлення нічної версії і таргету wasm
rustup default stable
rustup update
rustup update nightly
rustup target add wasm32-unknown-unknown --toolchain nightly

  # Встановлення Go
  sudo rm -rf /usr/local/go
  curl -L https://go.dev/dl/go1.21.6.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
  echo 'export PATH=\$PATH:/usr/local/go/bin:\$HOME/go/bin' >> \$HOME/.bash_profile
  source \$HOME/.bash_profile

  # Встановлення Node Version Manager (nvm)
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
  source ~/.bashrc
  nvm install --lts


  echo 'Усі пакети встановлені та налаштовані.'
"

echo "Всі команди запущені у новій screen сесії з ім'ям 'upgrade'."
