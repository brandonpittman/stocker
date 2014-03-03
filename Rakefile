require "bundler/gem_tasks"
require "rake/testtask"
require 'cucumber'
require 'cucumber/rake/task'

Rake::TestTask.new do |t|
    t.libs << 'test'
      t.test_files = FileList['test/*.rb']
end

Cucumber::Rake::Task.new(:features) do |t|
    t.cucumber_opts = "features --format pretty"
end

task(default: :test)
