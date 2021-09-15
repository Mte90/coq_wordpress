#!/usr/bin/env bash
set -o errexit

cd $(dirname $0)

cd ./wp-hooks
curl -O https://raw.githubusercontent.com/johnbillion/wp-hooks/master/hooks/actions.json
curl -O https://raw.githubusercontent.com/johnbillion/wp-hooks/master/hooks/filters.json
