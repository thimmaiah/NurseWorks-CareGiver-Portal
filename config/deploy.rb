# config valid for current version and patch releases of Capistrano
lock "~> 3.16.0"

set :application, "NurseWorks"
set :repo_url, "https://github.com/thimmaiah/NurseWorks-CareGiver-Portal.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
set :branch, 'main'

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/ubuntu/NurseWorks"
set :ssh_options, forward_agent: :true 
set :ssh_options, keys: "/home/thimmaiah/.ssh/NurseWorks.pem" 

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, false  # Change to true if using ActiveRecord

namespace :deploy do

  desc "Uploads .env remote servers."
  task :upload_env do
    on roles(:app) do
      rails_env = fetch(:rails_env)
      puts "Uploading .env files to #{release_path} #{rails_env}"
      upload!("/data/work/NurseWorks/.env", "#{release_path}", recursive: false)
      upload!("/data/work/NurseWorks/.env.local", "#{release_path}", recursive: false)
      upload!("/data/work/NurseWorks/.env.staging", "#{release_path}", recursive: false) if rails_env == :staging
      upload!("/data/work/NurseWorks/.env.production", "#{release_path}", recursive: false) if rails_env == :production      
    end
  end

  before "deploy:assets:precompile", :upload_env

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end
  
end


namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  # before :start, :make_dirs
end