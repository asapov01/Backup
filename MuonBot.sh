#!/bin/bash


status=$(curl -s http://localhost:8012/status | jq -r '.network.nodeInfo.active')


ip_address=$(hostname -I | awk '{print $1}')


if [ "$status" = "false" ]; then
    
    message="IP Server: $ip_address, node status: false"

    
    curl -s -X POST \
        -H 'Content-Type: application/json' \
        -d "{\"chat_id\": \"459515129\", \"text\": \"$message\"}" \
        https://api.telegram.org/bot6570530801:AAFrdXFIOBIJmRTt54Sa5SbDtGAwTpBiuJ0/sendMessage
else
    
    echo "Статус не активний"
    
    
    detailed_status=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8012/status)
    
    if [ "$detailed_status" != "200" ]; then
        
        message="IP Server: $ip_address, HTTP error code: $detailed_status"
        curl -s -X POST \
            -H 'Content-Type: application/json' \
            -d "{\"chat_id\": \"459515129\", \"text\": \"$message\"}" \
            https://api.telegram.org/bot6570530801:AAFrdXFIOBIJmRTt54Sa5SbDtGAwTpBiuJ0/sendMessage
    else
        
        echo "Статус: $status"
    fi
fi
