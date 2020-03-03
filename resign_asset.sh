#!/bin/bash
set -e
set -x
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# import certificate
security create-keychain -p $KEYCHAIN_PASSWORD "${DIR}/appbuilder/appbuilder.keychain"
security import "${DIR}/appbuilder/secrets/Certificates.p12" -t agg -k "${DIR}/appbuilder/appbuilder.keychain" -P $CERTIFICATE_PASSWORD -A

# set keychain
security list-keychains -s "${DIR}/appbuilder/appbuilder.keychain"
security default-keychain -s "${DIR}/appbuilder/appbuilder.keychain"
security unlock-keychain -p "${KEYCHAIN_PASSWORD}" "${DIR}/appbuilder/appbuilder.keychain"
security find-identity -p codesigning -v
SIGNING_IDENTITY=$(security find-identity -p codesigning -v | grep "^  \d)" | cut -d\" -f2)
echo "SIGNING_IDENTITY=${SIGNING_IDENTITY}"

# resign app
mkdir -p "${DIR}/result"
EXT="${APPBUILDER_ASSET##*.}"
APPBUILDER_RESULT="${APPBUILDER_ASSET%.*}-resigned.${EXT}"
./resign.sh "${DIR}/asset/${APPBUILDER_ASSET}" "${SIGNING_IDENTITY}" -p "${DIR}/appbuilder/secrets/app.mobileprovision" "${DIR}/result/${APPBUILDER_RESULT}"

