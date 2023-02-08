#!/bin/bash
set -e

rm -f /myapp/tmp/pids/server.pid

rails db:create
rails db:migrate

exec "$@"
