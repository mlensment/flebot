require 'mina/bundler'
require 'mina/git'
require 'mina/rbenv'  # for rbenv support. (http://rbenv.org)

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :domain, 'yellow'
set :deploy_to, '/home/deployer/projects/flebot'
set :repository, 'git@github.com:mlensment/flebot.git'
set :branch, 'master'

# For system-wide RVM install.
#   set :rvm_path, '/usr/local/rvm/bin/rvm'

# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, ['config.yml', 'app-data', 'log']

# Optional settings:
set :user, 'deployer'    # Username in the server to SSH to.
#   set :port, '30000'     # SSH port number.
set :forward_agent, true     # SSH forward_agent.

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .ruby-version or .rbenv-version to your repository.
  invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  # invoke :'rvm:use[ruby-1.9.3-p125@default]'
end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/app-data"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/app-data"]

  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/log"]

  queue! %[touch "#{deploy_to}/#{shared_path}/config.yml"]

  queue  %[echo "-----> Be sure to edit '#{deploy_to}/#{shared_path}/config.yml'."]

  queue %[
    repo_host=`echo $repo | sed -e 's/.*@//g' -e 's/:.*//g'` &&
    repo_port=`echo $repo | grep -o ':[0-9]*' | sed -e 's/://g'` &&
    if [ -z "${repo_port}" ]; then repo_port=22; fi &&
    ssh-keyscan -p $repo_port -H $repo_host >> ~/.ssh/known_hosts
  ]
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  to :before_hook do
    # Put things to run locally before ssh
  end
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'deploy:cleanup'

    to :launch do
      puts "nohup ruby #{deploy_to}/#{current_path}/flebot.rb --start FLEBOT_ENV=production &> #{deploy_to}/#{current_path}/log/production.log &"
      # queue "nohup #{deploy_to}/#{current_path}/flebot.rb --start FLEBOT_ENV=production &> #{deploy_to}/#{current_path}/log/production.log &"
    end
  end
end

task :start do
  queue! "kill $(ps -fu deployer | grep '[f]lebot.rb' | awk '{print $2}')"
end

task :stop do
  queue! "kill $(ps -fu deployer | grep '[f]lebot.rb' | awk '{print $2}')"
end

# For help in making your deploy script, see the Mina documentation:
#
#  - http://nadarei.co/mina
#  - http://nadarei.co/mina/tasks
#  - http://nadarei.co/mina/settings
#  - http://nadarei.co/mina/helpers
