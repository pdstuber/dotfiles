#!/usr/bin/env sh
set -eu

VARIANT=$1
apply() {
  go install github.com/pdstuber/homemaker@v1.0.0
  eval $(go env)
  "${GOPATH}/bin/homemaker" --variant "${VARIANT}" --verbose homemaker.toml .
}

if ! command -v go version &> /dev/null
then
    echo "please install go first"
    exit 1
fi

apply