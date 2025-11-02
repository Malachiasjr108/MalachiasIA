#!/bin/bash
# Uso: ./add_command.sh "comando"
cmd="$1"
if [ -z "$cmd" ]; then
  echo "Uso: $0 'comando'"
  exit 1
fi
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "$timestamp | PENDING | $cmd" >> ~/Malachias/command_queue.txt
echo "✅ Comando adicionado à fila: $cmd"
