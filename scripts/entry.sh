/scripts/setup.sh &
MAIN_PROCESS=$!

_term() {
  echo "Restarting server"
  kill -15 "$MAIN_PROCESS"
  while ps -p "$MAIN_PROCESS" > /dev/null
  do
    sleep 0.5
  done
  /scripts/setup.sh &
  echo "Starting server"
  MAIN_PROCESS=$!
  wait "$MAIN_PROCESS"
}

_term2() {
  kill -15 "$MAIN_PROCESS"
  wait "$MAIN_PROCESS"
}

trap _term SIGHUP
trap _term2 SIGTERM

wait "$MAIN_PROCESS"

