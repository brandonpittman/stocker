$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require "stocker_version"

Gem::Specification.new do |s|
  s.name        = 'stocker'
  s.version     = Stocker::VERSION
  s.date        = '2014-02-19'
  s.summary     = "stocker is a lightweight home inventory application."
  s.description = "stocker will help track how many of something you have on hand."
  s.authors     = ["Brandon Pittman"]
  s.email       = 'brandonpittman@gmail.com'
  s.files       = ["lib/stocker.rb"]
  s.homepage    = 'http://github.com/brandonpittman/stocker'
  s.license     = 'MIT'
  s.executables << 'stocker'
  s.add_dependency("thor", "~> 0.18")
  s.add_dependency("titleize", "~>1.3")
end
