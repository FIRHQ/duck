# /usr/bin/env bash
redis-server &
puma -C puma.rb &
bundle exec thin start -C config/thin.yml &
read
