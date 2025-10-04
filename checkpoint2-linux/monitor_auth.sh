#!/usr/bin/env bash

SERVICE_NAME="monitor_auth"
AUTH_LOG="/var/log/auth.log"
LOG_FILE="/var/log/${SERVICE_NAME}_log.log"
PID_FILE="/run/${SERVICE_NAME}.pid"

ts() { date '+%Y-%m-%d %H:%M:%S'; }
log() { echo "$(ts) [$SERVICE_NAME] $*" | tee -a "$LOG_FILE"; }

require_root() {
  if [ "$EUID" -ne 0 ]; then
    echo "Precisa rodar como root."; exit 1
  fi
}

start() {
  require_root
  if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    log "Já está em execução (PID $(cat "$PID_FILE"))."; exit 0
  fi
  touch "$LOG_FILE" || exit 1
  mkdir -p /run
  (
    trap 'log "Finalizando..."; exit 0' TERM INT
    trap 'log "Reload recebido";' HUP
    log "Iniciando monitoramento..."
    tail -Fn0 "$AUTH_LOG" | while read -r line; do
      if echo "$line" | grep -Eiq 'session opened for user|Accepted (password|publickey)|Failed password|invalid user|authentication failure'; then
        log "EVENTO: $line"
      fi
    done
  ) &
  echo $! > "$PID_FILE"
  log "Iniciado com PID $(cat "$PID_FILE")."
  wait %1
}

stop() {
  require_root
  if [ -f "$PID_FILE" ]; then
    PID="$(cat "$PID_FILE")"
    if kill -0 "$PID" 2>/dev/null; then
      log "Parando PID $PID"
      kill -TERM "$PID"
      sleep 1
      rm -f "$PID_FILE"
      log "Parado."
      exit 0
    fi
  fi
  log "Não estava em execução."
}

reload() {
  require_root
  if [ -f "$PID_FILE" ]; then
    PID="$(cat "$PID_FILE")"
    kill -HUP "$PID" 2>/dev/null && log "Reload enviado para PID $PID" && exit 0
  fi
  log "Serviço não está rodando."
  exit 1
}

status_cmd() {
  if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    echo "$SERVICE_NAME: RUNNING (PID $(cat "$PID_FILE"))"; exit 0
  else
    echo "$SERVICE_NAME: STOPPED"; exit 3
  fi
}

case "$1" in
  start) start ;;
  stop) stop ;;
  reload) reload ;;
  status) status_cmd ;;
  *) echo "Uso: $0 {start|stop|reload|status}"; exit 2 ;;
esac
