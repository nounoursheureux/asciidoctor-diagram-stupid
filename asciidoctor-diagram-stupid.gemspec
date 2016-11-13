# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'version'

Gem::Specification.new do |spec|
  spec.name          = "asciidoctor-diagram-stupid"
  spec.version       = Asciidoctor::Diagram::Stupid::VERSION
  spec.authors       = ["Wilhem Barbier"]
  spec.email         = ["nounoursheureux@openmailbox.org"]

  spec.summary       = %q{Generate Stupid diagrams with Asciidoctor.}
  spec.description   = %q{Generate Stupid diagrams with Asciidoctor.}
  spec.homepage      = "https://github.com/nounoursheureux/asciidoctor-diagram-stupid"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_runtime_dependency "asciidoctor", "~> 1.5"
  spec.add_runtime_dependency "asciidoctor-diagram", "~> 1.5"
end
