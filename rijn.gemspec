require_relative "lib/rijn/version"

Gem::Specification.new do |spec|
  spec.name = "rijn"
  spec.version = Rijn::VERSION
  spec.summary = "A small CLI for AES-GCM encryption"
  spec.authors = ["matthew-moritz"]

  spec.license = "MIT"
  spec.homepage = "https://github.com/matthew-moritz/rijn"
  spec.required_ruby_version = ">= 3.4"

  spec.files = Dir["lib/**/*", "bin/*", "LICENSE.md"]
  spec.bindir = "bin"
  spec.executables = ["rijn"]

  spec.add_dependency "base64"
  spec.add_dependency "pastel"
  spec.add_dependency "thor"
  spec.add_dependency "tty-prompt"
end
