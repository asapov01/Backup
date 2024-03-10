#!/bin/bash

# Получение статуса
status=$(curl -s http://localhost:8012/status | jq -r '.network.nodeInfo.active')

# Получение IP-адреса сервера
ip_address=$(hostname -I | awk '{print $1}')

# Проверка статуса
if [ "$status" = "false" ]; then
    # Формирование сообщения о статусе
    message="IP Server: $ip_address, node status: active"

    # Отправка сообщения в телеграм
    curl -s -X POST \
        -H 'Content-Type: application/json' \
        -d "{\"chat_id\": \"459515129\", \"text\": \"$message\"}" \
        https://api.telegram.org/bot6570530801:AAFrdXFIOBIJmRTt54Sa5SbDtGAwTpBiuJ0/sendMessage
else
    # Вывод сообщения о неактивном статусе
    echo "Статус не активный"
    
    # Проверка статуса сервера по HTTP-коду
    detailed_status=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8012/status)
    
    if [ "$detailed_status" != "200" ]; then
        # Отправка уведомления об ошибке в телеграм
        message="IP Server: $ip_address, HTTP error code: $detailed_status"
        curl -s -X POST \
            -H 'Content-Type: application/json' \
            -d "{\"chat_id\": \"459515129\", \"text\": \"$message\"}" \
            https://api.telegram.org/bot6570530801:AAFrdXFIOBIJmRTt54Sa5SbDtGAwTpBiuJ0/sendMessage
    else
        # Вывод сообщения о статусе
        echo "Статус: $status"
    fi
fi
