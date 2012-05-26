require 'rake/testtask'
require 'rake/rdoctask'
require 'bundler/setup'
Bundler.require

Rake::TestTask.new do |task|
  task.libs << 'test'
end

Rake::RDocTask.new do |rd|
end

Gokdok::Dokker.new do |gd|
  gd.repo_url = 'git@github.com:foursquare/wait.git'
end

desc 'Run tests'
task :default => :test
