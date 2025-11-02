#!/bin/bash
QUEUE=~/Malachias/command_queue.txt
LOG=~/Malachias/command_log.txt

echo "=============================================="
echo " MALACHIAS - FILA DE COMANDOS PENDENTES"
echo "=============================================="

if [ ! -s "$QUEUE" ]; then
  echo "Nenhum comando pendente!"
  exit 0
fi

nl -ba "$QUEUE"

echo
read -p "Digite o número do comando para revisar (ou 'a' para todos): " sel

run_cmd() {
  line="$1"
  cmd=$(echo "$line" | cut -d'|' -f3- | sed 's/^ *//; s/ *$//')
  ts=$(echo "$line" | cut -d'|' -f1)
  echo
  echo "---------------------------------------------"
  echo "Comando: $cmd"
  echo "---------------------------------------------"
  read -p "Executar este comando? (y/N): " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "$ts | EXECUTANDO | $cmd" >> "$LOG"
    echo "Executando comando: $cmd"
    bash -c "$cmd" 2>&1 | tee -a "$LOG"
    echo "$ts | FINALIZADO | $cmd" >> "$LOG"
    echo "✅ Concluído."
  else
    echo "$ts | CANCELADO | $cmd" >> "$LOG"
    echo "❌ Cancelado."
  fi
}

if [[ "$sel" == "a" ]]; then
  while IFS= read -r line; do
    run_cmd "$line"
  done < "$QUEUE"
  > "$QUEUE"
else
  line=$(sed -n "${sel}p" "$QUEUE")
  if [ -z "$line" ]; then
    echo "Número inválido."
    exit 1
  fi
  run_cmd "$line"
  sed -i "${sel}d" "$QUEUE"
fi
