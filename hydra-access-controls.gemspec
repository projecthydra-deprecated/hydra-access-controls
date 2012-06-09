# -*- encoding: utf-8 -*-
require File.expand_path('../lib/hydra-access-controls/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Justin Coyne"]
  gem.email         = ["justin.coyne@yourmediashelf.com"]
  gem.description   = %q{Access controls for project hydra}
  gem.summary       = %q{Access controls for project hydra}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "hydra-access-controls"
  gem.require_paths = ["lib"]
  gem.version       = Hydra::Access::Controls::VERSION

  gem.add_dependency 'activesupport'
  gem.add_dependency 'active-fedora'
  gem.add_dependency 'cancan'
  gem.add_dependency 'deprecation'

  gem.add_development_dependency 'rspec'
  
end
