FILE_PATH=$1
MAX_BYTES=$2

if [ -n "$(find "$FILE_PATH" -prune -size +${MAX_BYTES}c)" ]; then
  echo >&2 "File is over the maximum size"
  exit 1
fi

cat $FILE_PATH
