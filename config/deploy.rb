# config valid only for current version of Capistrano
lock '3.5.0'

set :application, 'duck'
set :repo_url, 'git@github.com:FIRHQ/duck.git'
set :deploy_to, '/var/www/duck'
set :deploy_user, 'deploy'
set :slack_webhook, 'https://hooks.slack.com/services/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'

set :default_env,   'env_var1' => 'value1',
                    'env_var2' => 'value2',
                    'DUCK_REDIS_HOST' => "127.0.0.1"
set :rvm_ruby_version, '2.3.1'

set :puma_user, fetch(:user)
set :puma_threads, [20, 32]
set :puma_rackup, -> { File.join(current_path, 'message.ru') }
set :puma_workers, 2
set :puma_pid, "#{shared_path}/tmp/puma/puma.pid"
set :puma_state, "#{shared_path}/tmp/puma/puma.state"
set :puma_bind, ["tcp://0.0.0.0:4001"]

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

set :linked_dirs, %w(log tmp/puma tmp/cache tmp/sockets vendor/bundle public/system)
# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :rvm_type, :auto
set :rvm_ruby_version, '2.3.1'
set :rvm_roles, [:app, :web, :db]

namespace :deploy do
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
      run
    end
  end
end
