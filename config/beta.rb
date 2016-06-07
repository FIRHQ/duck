set :deploy_user, 'deploy'
set :stage, :beta
set :branch, 'develop'
set :rails_env, :production
server '192.168.10.4', user: 'deploy', roles: %w(web app db), primary: true
server '192.168.10.5', user: 'deploy', roles: %w(web app db), primary: true
server '192.168.10.6', user: 'deploy', roles: %w(web app db), primary: true
