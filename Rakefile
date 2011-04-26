require 'bundler'
require 'rake/clean'
require 'rubygems'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rcov/rcovtask'
require 'sdoc'
require 'grancher/task'
require 'rake/testtask'

Grancher::Task.new do |g|
  g.branch = 'gh-pages'
  g.push_to = 'origin'
  g.directory 'html'
end


Rake::RDocTask.new(:rdoc) do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("README.rdoc","lib/**/*.rb","bin/**/*")
  rd.options << '--fmt' << 'shtml'
  rd.template = 'direct'
  rd.title = 'crazylegs'
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/tc_*.rb']
end

task :clobber_coverage do
  rm_rf "coverage"
end

desc 'Measures test coverage'
task :coverage => :rcov do
  puts "coverage/index.html contains what you need"
end

Rcov::RcovTask.new do |t|
  t.libs << 'lib'
  t.test_files = FileList['test/tc_*.rb']
end

task :default => :test

Bundler::GemHelper.install_tasks

desc 'Publish rdoc on github pages and push to github'
task :publish_rdoc => [:rdoc,:publish]
