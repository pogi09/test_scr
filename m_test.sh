#!/bin/bash

# Скрипт для мониторинга процесса "test"
# Файл: /usr/local/bin/monitor_test.sh

PID_FILE=/var/run/test_monitor.pid
LOG_FILE=/var/log/monitoring.log
URL="https://test.com/monitoring/test/api"

# Проверяем, запущен ли процесс "test"
if pgrep -x "test" > /dev/null; then
    # Получаем PID самого старого процесса (предполагаем один основной процесс)
    CURRENT_PID=$(pgrep -o -x "test")

    # Проверяем предыдущий PID
    if [ -f "$PID_FILE" ]; then
        PREV_PID=$(cat "$PID_FILE")
        if [ "$CURRENT_PID" != "$PREV_PID" ]; then
            echo "$(date '+%Y-%m-%d %H:%M:%S'): Process test restarted. New PID: $CURRENT_PID" >> "$LOG_FILE"
        fi
    fi

    # Обновляем файл с PID
    echo "$CURRENT_PID" > "$PID_FILE"

    # Отправляем HTTPS-запрос
    curl -s -f "$URL" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S'): Monitoring server unavailable: $URL" >> "$LOG_FILE"
    fi
else
    # Если процесс не запущен, ничего не делаем (не удаляем PID-файл, чтобы детектировать перезапуск при следующем запуске)
    :
fi
