require 'rake/testtask'
require 'bundler/gem_tasks'
require 'yard'

task default: :test

Rake::TestTask.new do |t|
  t.libs.push 'test'
  t.pattern = 'test/**/*_test.rb'
  t.warning = true
  t.verbose = true  
end

YARD::Rake::YardocTask.new do |task|
  task.files = ['lib/**/*.rb']
end
