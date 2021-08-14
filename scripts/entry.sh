/scripts/setup.sh &
MAIN_PROCESS=$!
RESTARTING="0"
CLOSING="0"

kill_server() {
  CLOSING="1"
  kill -15 "$MAIN_PROCESS"
  wait "$MAIN_PROCESS"
}

restart_server() {
  AUTO_RESTART=$1

  if [ "${RESTARTING}" = "1" ]; then
    echo "Server is already stopped/restarting, please wait"
    return
  fi
  RESTARTING="1"

  echo "Stopping server"
  kill -15 "$MAIN_PROCESS"
  while ps -p "$MAIN_PROCESS" > /dev/null
  do
    sleep 0.5
  done

  # input signal must not already be there, so delete it if it is
  if [ -f /paper/server-restart-lock ]; then
    rm /paper/server-restart-lock
  fi

  # wait for input signal before starting unless AUTO_RESTART = 1
  if [ "${AUTO_RESTART}" != "1" ]; then
    while true
    do
      if [ -f /paper/server-restart-lock ]; then
        rm /paper/server-restart-lock
        break
      fi
      if [ "${CLOSING}" = "1" ]; then
        return
      fi
      sleep 1s
    done
  fi

  /scripts/setup.sh &
  echo "Starting server"
  MAIN_PROCESS=$!
  RESTARTING="0"
  wait "$MAIN_PROCESS"
}

_term() {
  kill_server
}

_term2() {
  restart_server "1"
}

_term3() {
  restart_server "0"
}

trap _term SIGTERM
trap _term2 SIGHUP
trap _term3 SIGFPE

wait "$MAIN_PROCESS"

