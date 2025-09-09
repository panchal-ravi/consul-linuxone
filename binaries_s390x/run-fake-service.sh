#!/bin/bash

FAKE_SERVICE=/opt/myapp/fake-service
GLIBC_DIR="/root/glibc-2.34/install"

exec "$GLIBC_DIR/lib/ld64.so.1" \
  "$FAKE_SERVICE" "$@"