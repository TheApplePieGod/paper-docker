TARGET_PATH=$1
TEMP_NAME=$2

xxd -r -p - "${TARGET_PATH}/${TEMP_NAME}"

tar -xf "${TARGET_PATH}/${TEMP_NAME}" -C "${TARGET_PATH}"
rm "${TARGET_PATH}/${TEMP_NAME}"