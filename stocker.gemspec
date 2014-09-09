$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require "stocker/version"

Gem::Specification.new do |s|
  s.name        = 'stocker'
  s.version     = Stocker::VERSION
  s.date        = '2014-02-22'
  s.summary     = "stocker is a lightweight home inventory application."
  s.description = "stocker will help track how many of something you have on hand."
  s.authors     = ["Brandon Pittman"]
  s.email       = 'brandonpittman@gmail.com'
  s.files       = ["lib/stocker.rb"]
  s.homepage    = 'http://github.com/brandonpittman/stocker'
  s.license     = 'MIT'
  s.executables << 'stocker'
  s.add_dependency("thor")
  s.add_dependency("rake")
  s.add_dependency("titleize")
  s.add_development_dependency("rspec")
end
