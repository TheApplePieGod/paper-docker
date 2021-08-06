TARGET_PATH=$1
TEMP_NAME=$2
FILE_SIZE_KB=$3
FILE_SIZE_B=$4

FREE=$(df -k --output=avail "${TARGET_PATH}" | tail -n1)
if [ ${FREE} -lt ${FILE_SIZE_KB} ]; then
  echo >&2 "Not enough space for the file"
  exit 1
fi

xxd -r -p - "${TARGET_PATH}/${TEMP_NAME}"

TEMP_FILE_SIZE_B=$(stat --printf="%s" "${TARGET_PATH}/${TEMP_NAME}")

if [ ${TEMP_FILE_SIZE_B} -ge $((${FILE_SIZE_B}-1000)) ]; then
  tar -xf "${TARGET_PATH}/${TEMP_NAME}" -C "${TARGET_PATH}"
else
  echo >&2 "File upload was not complete, cancelling unzip"
fi

rm "${TARGET_PATH}/${TEMP_NAME}"
