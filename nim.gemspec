# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "nim/version"

Gem::Specification.new do |s|
  s.name        = "nim"
  s.version     = Nim::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["takafan"]
  s.email       = ["takafan@163.com"]
  s.homepage    = "http://github.com/takafan/nim"
  s.summary     = %q{Nim}
  s.description = %q{play nim game with Q, Whom nim the last one bean were *lost*}

  s.rubyforge_project = "nim"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
