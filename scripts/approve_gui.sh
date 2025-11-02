#!/bin/bash
QUEUE=~/Malachias/command_queue.txt
LOG=~/Malachias/command_log.txt

# Verifica se há comandos pendentes
if [ ! -s "$QUEUE" ]; then
  zenity --info --title="Malachias AI" --text="Nenhum comando pendente para aprovar." --width=250
  exit 0
fi

# Lê todos os comandos pendentes
mapfile -t lines < "$QUEUE"

# Cria lista numerada
options=""
for i in "${!lines[@]}"; do
  cmd=$(echo "${lines[$i]}" | cut -d'|' -f3- | sed 's/^ *//; s/ *$//')
  options+="$(($i+1)) $cmd "
done

# Mostra janela com a lista de comandos
choice=$(zenity --list \
  --title="Malachias - Aprovação de comandos" \
  --text="Escolha um comando para executar:" \
  --column="Nº" --column="Comando" \
  $options --width=800 --height=400)

# Se o usuário cancelou
if [ -z "$choice" ]; then
  exit 0
fi

# Pega a linha correspondente
line="${lines[$((choice-1))]}"
cmd=$(echo "$line" | cut -d'|' -f3- | sed 's/^ *//; s/ *$//')
ts=$(echo "$line" | cut -d'|' -f1)

# Confirma execução
zenity --question \
  --title="Confirmar execução" \
  --text="Deseja executar este comando?\n\n$cmd" \
  --width=500
if [ $? -ne 0 ]; then
  echo "$ts | CANCELADO | $cmd" >> "$LOG"
  zenity --info --text="Comando cancelado." --width=250
  exit 0
fi

# Executa o comando
echo "$ts | EXECUTANDO | $cmd" >> "$LOG"
(
  bash -c "$cmd"
) | zenity --progress \
  --title="Executando comando..." \
  --text="Rodando: $cmd" \
  --pulsate --auto-close --no-cancel --width=500

rc=${PIPESTATUS[0]}
if [ $rc -eq 0 ]; then
  echo "$ts | FINALIZADO | $cmd" >> "$LOG"
  zenity --info --text="✅ Comando executado com sucesso." --width=250
else
  echo "$ts | ERRO($rc) | $cmd" >> "$LOG"
  zenity --error --text="❌ O comando retornou erro ($rc)." --width=250
fi

# Remove o comando executado da fila
sed -i "${choice}d" "$QUEUE"
