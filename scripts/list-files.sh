ROOT_PATH=$1

cd "${ROOT_PATH}"

du -hs $(ls -pA) 2> >(grep -v '^du: cannot \(access\|read\)' >&2)
