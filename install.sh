#!/usr/bin/env bash
set -o errexit

cd $(dirname $0)

cd ./wp-hooks
curl -O https://raw.githubusercontent.com/johnbillion/wp-hooks/master/hooks/actions.json > /dev/null
curl -O https://raw.githubusercontent.com/johnbillion/wp-hooks/master/hooks/filters.json > /dev/null
