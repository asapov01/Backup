#!/bin/bash

# Автоматично визначає інтерфейс з префіксом "enp"
INTERFACE=$(ip -o link show | awk -F': ' '{print $2}' | grep enp | head -n 1)

# Якщо інтерфейс не знайдений
if [ -z "$INTERFACE" ]; then
  echo "Не знайдено мережевий інтерфейс з префіксом 'enp'."
  exit 1
fi

# Запит на введення IP та MAC адреси
echo "Виявлений інтерфейс: $INTERFACE"
read -p "Введіть IP-адресу (наприклад, 135.181.219.90/26): " IP
read -p "Введіть MAC-адресу (наприклад, 00:50:56:00:E1:D7): " MAC
read -p "Введіть ім'я контейнера: " CONTAINER_NAME

# Отримуємо шлюз з ip route
GATEWAY=$(ip route | grep default | awk '{print $3}')

# Перевірка, чи знайдений шлюз
if [ -z "$GATEWAY" ]; then
  echo "Не вдалося знайти шлюз за замовчуванням."
  exit 1
fi

# Файл конфігурації контейнера
LXC_CONFIG="/var/lib/lxc/$CONTAINER_NAME/config"

# Оновлення або додавання мережевої конфігурації в файл
sudo tee $LXC_CONFIG > /dev/null <<EOF
# Distribution configuration
lxc.include = /usr/share/lxc/config/common.conf
lxc.arch = linux64

# Container specific configuration
lxc.rootfs.path = dir:/var/lib/lxc/$CONTAINER_NAME/rootfs
lxc.uts.name = $CONTAINER_NAME

# Network configuration
lxc.net.0.type = macvlan
lxc.net.0.link = $INTERFACE
lxc.net.0.macvlan.mode = bridge
lxc.net.0.hwaddr = $MAC
lxc.net.0.ipv4.address = $IP
lxc.net.0.ipv4.gateway = $GATEWAY
lxc.net.0.flags = up

# Enable autostart
lxc.start.auto = 1
lxc.start.delay = 5
EOF

# Перезавантаження контейнера з новими параметрами
sudo lxc-stop -n $CONTAINER_NAME
sudo lxc-start -n $CONTAINER_NAME

echo "Конфігурацію контейнера $CONTAINER_NAME оновлено. Контейнер перезавантажено."
