set :deploy_user, 'deploy'
set :stage, :beta
set :branch, 'develop'
set :rails_env, :production
server '192.168.10.7', user: 'deploy', roles: %w(web app db), primary: true
server '192.168.10.8', user: 'deploy', roles: %w(web app db), primary: true
