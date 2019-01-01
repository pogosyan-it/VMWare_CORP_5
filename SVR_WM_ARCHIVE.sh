#!/bin/bash

ssh -T  10.10.1.6 << EOF                #  Соединение по ключу с сервером
bash /home/it/scripts/WM_uptime.sh      # Запускаем скрипт
exit                                   # Закрываем ssh
EOF

