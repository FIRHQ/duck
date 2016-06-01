# /usr/bin/env bash
redis-server &
ruby realtime.rb & 
bundle exec thin start -C thin.yml
