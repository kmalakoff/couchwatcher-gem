# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{couchwatcher}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Kevin Malakoff"]
  s.date = %q{2011-06-18}
  s.description = %q{This gem provides a simple library to watch a couchdb database or specific documents and to receieve notifications when they change.}
  s.email = %q{xmann.intl@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "lib/couchwatcher.rb",
    "lib/couchwatcher/database_listener.rb",
    "test/helper.rb",
    "test/test_couchwatcher.rb"
  ]
  s.homepage = %q{http://github.com/kmalakoff/couchwatcher-gem}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.5.2}
  s.summary = %q{Couch document uploading utility}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<json>, ["> 1.1.5"])
      s.add_runtime_dependency(%q<typhoeus>, ["~> 0.2"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.6.2"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
      s.add_runtime_dependency(%q<json>, ["> 1.1.5"])
      s.add_runtime_dependency(%q<typhoeus>, ["~> 0.2"])
    else
      s.add_dependency(%q<json>, ["> 1.1.5"])
      s.add_dependency(%q<typhoeus>, ["~> 0.2"])
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.6.2"])
      s.add_dependency(%q<rcov>, [">= 0"])
      s.add_dependency(%q<json>, ["> 1.1.5"])
      s.add_dependency(%q<typhoeus>, ["~> 0.2"])
    end
  else
    s.add_dependency(%q<json>, ["> 1.1.5"])
    s.add_dependency(%q<typhoeus>, ["~> 0.2"])
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.6.2"])
    s.add_dependency(%q<rcov>, [">= 0"])
    s.add_dependency(%q<json>, ["> 1.1.5"])
    s.add_dependency(%q<typhoeus>, ["~> 0.2"])
  end
end

