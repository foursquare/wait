require 'rake/testtask'
require 'bundler/setup'
Bundler.require

Rake::TestTask.new do |task|
  task.libs << 'test'
end

desc 'Run tests'
task :default => :test
