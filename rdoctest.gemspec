$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), 'lib'))
require 'rdoctest/version'

Gem::Specification.new do |s|
  s.date = "2010-12-05"

  s.name = "rdoctest"
  s.version = Rdoctest::Version::VERSION.dup
  s.summary = "A doctest for Ruby."
  s.description = "Scans RDoc text for examples and tests them."

  s.executables = %w(rdoctest)
  s.default_executable = "rdoctest"

  s.files = Dir["README.rdoc", "Rakefile", "lib/**/*"]
  s.test_files = Dir["test/**/*"]

  s.extra_rdoc_files = %w(README.rdoc)
  s.has_rdoc = true
  s.rdoc_options = %w(--main README.rdoc)

  s.author = "Stephen Celis"
  s.email = "stephen@stephencelis.com"
  s.homepage = "http://github.com/stephencelis/rdoctest"
end
