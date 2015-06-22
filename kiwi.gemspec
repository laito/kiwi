# Maintaining gem's version
require 'kiwi/version'

Gem::Specification.new do |spec|
  spec.name          = 'kiwi'
  spec.version       = Kiwi::VERSION
  spec.authors       = ['Apoorv Singh']
  spec.email         = ['apoorv11028@iiitd.ac.in']
  spec.summary       = 'Kiwi is a simple and distributed key value store'
  spec.homepage      = 'http://github.com/laito/kiwi'
  spec.license       = 'MIT'
  spec.files         = ['lib/kiwi.rb']
  spec.executables   = ['bin/kiwi']
  spec.require_paths = ['lib']

  spec.add_dependency 'eventmachine', '~> 1.0.7'
  spec.add_dependency 'em-synchrony', '~> 1.0.4'
end
