# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "couchwatcher"
  gem.homepage = "http://github.com/kmalakoff/couchwatcher-gem"
  gem.license = "MIT"
  gem.summary = %Q{Couch document uploading utility}
  gem.description = %Q{This gem provides a simple library to watch a couchdb database or specific documents and to receieve notifications when they change.}
  gem.email = "xmann.intl@gmail.com"
  gem.authors = ["Kevin Malakoff"]

  gem.add_dependency 'json', '> 1.1.5'
  gem.add_dependency 'typhoeus', '~>0.2'
  gem.add_dependency 'thor', '~>0.14.0'
  gem.files.include 'lib/couchwatcher/database_listener.rb'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
  test.rcov_opts << '--exclude "gems/*"'
end

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "couchwatcher #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
