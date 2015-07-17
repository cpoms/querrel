# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'querrel/version'

Gem::Specification.new do |spec|
  spec.name          = "querrel"
  spec.version       = Querrel::VERSION
  spec.authors       = ["Mike Campbell"]
  spec.email         = ["mike@wordofmike.net"]
  spec.summary       = %q{Parallel query for ActiveRecord}
  spec.homepage      = "https://github.com/meritec/querrel"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activerecord", "~> 4.1"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 0"
  spec.add_development_dependency "sqlite3", "~> 1.3.5"
  spec.add_development_dependency "database_rewinder", "~> 0"
end
