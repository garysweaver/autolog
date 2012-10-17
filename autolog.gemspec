# -*- encoding: utf-8 -*-  
$:.push File.expand_path("../lib", __FILE__)  
require "autolog/version" 

Gem::Specification.new do |s|
  s.name        = 'autolog'
  s.version     = Autolog::VERSION
  s.authors     = ['Gary S. Weaver']
  s.email       = ['garysweaver@gmail.com']
  s.homepage    = 'https://github.com/garysweaver/autolog'
  s.summary     = %q{Automatically logs Ruby events.}
  s.description = %q{Automatically log events like executed lines, methods, class and module definitions, C-language routines, and/or raises in Ruby.}
  s.files = Dir['lib/**/*'] + ['Rakefile', 'README.md']
  s.license = 'MIT'
end
