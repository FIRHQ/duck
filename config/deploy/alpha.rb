set :deploy_user, 'fir'
set :stage, :alpha
set :branch, 'feature/cap_deploy'
set :rails_env, :production
server '192.168.1.249', user: 'fir', roles: %w(web app db), primary: true
