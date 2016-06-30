$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "cerializable/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "cerializable"
  s.version     = Cerializable::VERSION
  s.authors     = ["Eric Arnold"]
  s.email       = ["eric.ed.arnold@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Cerializable."
  s.description = "TODO: Description of Cerializable."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.6"

  s.add_development_dependency "sqlite3"
end
