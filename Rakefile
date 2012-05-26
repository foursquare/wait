require 'rake/testtask'
require 'rdoc/task'
require 'bundler/setup'
Bundler.require

Rake::TestTask.new do |task|
  task.libs << 'test'
end

Rake::RDocTask.new do |rd|
  rd.title = 'Wait gem'
end

Gokdok::Dokker.new do |gd|
  gd.repo_url = 'git@github.com:foursquare/wait.git'
  gd.remote_path = './'
end

desc 'Run tests'
task :default => :test
