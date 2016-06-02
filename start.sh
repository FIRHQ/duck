# /usr/bin/env bash
redis-server &
puma -C puma.rb & 
bundle exec thin start -C thin.yml
