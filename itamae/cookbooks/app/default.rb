deploy_key = '/tmp/deploy.key'

remote_file deploy_key do
  owner node[:user]
end

git_ssh = '/usr/local/bin/git-ssh'

file git_ssh do
  owner 'root'
  mode '0755'
  content %Q(#!/bin/sh\nexec ssh -oIdentityFile=#{deploy_key} -oStrictHostKeyChecking=no "$@")
end

execute 'deploy app' do
  user node[:user]
  command <<"EOC"
GIT_SSH=#{git_ssh} git pull
ln -sf #{node[:deploy_to]}-tmp/app/webapp #{node[:deploy_to]}/webapp
EOC
  cwd "#{node[:deploy_to]}-tmp"
end

execute 'bundle i' do
  user node[:user]
  command <<"EOC"
~/local/ruby/bin/bundle install
EOC
  cwd "#{node[:deploy_to]}/webapp/ruby"
end

execute 'app restart' do
  command node[:app_restart]
  action :nothing
end
