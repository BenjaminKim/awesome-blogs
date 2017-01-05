#!/usr/bin/env puma

app_path = '/home/deploy/awesome-kore-blogs'
current_path = "#{app_path}/current"
shared_path = "#{app_path}/shared"

directory current_path
rackup "#{current_path}/config.ru"
environment 'production'

pidfile "#{shared_path}/tmp/pids/puma.pid"
state_path "#{shared_path}/tmp/pids/puma.state"
stdout_redirect "#{shared_path}/log/production.log", "#{shared_path}/log/production.log", true

threads 1,8
bind "unix://#{shared_path}/tmp/sockets/puma.sock"
workers 2
worker_timeout 30
prune_bundler
on_restart do
  puts 'Refreshing Gemfile'
  ENV['BUNDLE_GEMFILE'] = "#{current_path}/Gemfile"
end
plugin :tmp_restart