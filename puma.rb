root = "#{Dir.getwd}"

#bind "unix://#{root}/tmp/puma/socket"
pidfile "#{root}/tmp/puma/pid"
port 4567
environment 'production'
state_path "#{root}/tmp/puma/state"
rackup "#{root}/message.ru"
#rackup "#{root}/realtime.rb"

threads 8,32
workers 3
activate_control_app
