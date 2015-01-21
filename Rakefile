require 'bundler/gem_tasks'
require 'yard'

task default: :test

desc 'Run tests'
task :test do
  Dir.glob('test/**/*_test.rb').each do |file|
    require_relative file
  end
end

YARD::Rake::YardocTask.new do |task|
  task.files = ['lib/**/*.rb']
end
