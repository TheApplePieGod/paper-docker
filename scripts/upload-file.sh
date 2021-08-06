TARGET_PATH=$1
TEMP_NAME=$2
FILE_SIZE=$3

FREE=$(df -k --output=avail "${TARGET_PATH}" | tail -n1)
if [ ${FREE} -lt ${FILE_SIZE} ]; then
  echo >&2 "Not enough space for the file"
  exit 1
fi

xxd -r -p - "${TARGET_PATH}/${TEMP_NAME}"

tar -xf "${TARGET_PATH}/${TEMP_NAME}" -C "${TARGET_PATH}"
rm "${TARGET_PATH}/${TEMP_NAME}"
