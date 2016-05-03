# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'emiler/version'

Gem::Specification.new do |spec|
  spec.name          = 'emiler'
  spec.version       = Emiler::VERSION
  spec.authors       = ['Aleksei Matiushkin']
  spec.email         = ['aleksei.matiushkin@kantox.com']

  spec.summary       = 'Calculates the distance between two emails.'
  spec.description   = 'This library is kinda analogue of Jaro-Winkler distance between two emails.'
  spec.homepage      = 'https://kantox.com'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.' unless spec.respond_to?(:metadata)
  # spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'pry', '~> 0.10'

  spec.add_dependency 'fuzzy-string-match', '~> 0.9'
end