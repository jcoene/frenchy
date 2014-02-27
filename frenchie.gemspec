# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "frenchy/version"

Gem::Specification.new do |spec|
  spec.name          = "frenchy"
  spec.version       = Frenchy::VERSION
  spec.authors       = ["Jason Coene"]
  spec.email         = ["jcoene@gmail.com"]
  spec.description   = %q{Frenchy's got the goods}
  spec.summary       = %q{Frenchy's got the goods}
  spec.homepage      = "https://github.com/jcoene/frenchy"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activemodel"
  spec.add_dependency "activesupport"
  spec.add_dependency "http"
  spec.add_dependency "json"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
