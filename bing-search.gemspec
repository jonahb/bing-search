# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bing-search/version'

Gem::Specification.new do |spec|
  spec.name                  = 'bing-search'
  spec.version               = BingSearch::VERSION
  spec.authors               = ['Jonah Burke']
  spec.email                 = ['jonah@jonahb.com']
  spec.summary               = 'A Ruby client for the Bing Search API'
  spec.homepage              = 'http://github.com/jonahb/bing-search'
  spec.license               = 'MIT'
  spec.required_ruby_version = '>= 2.0'
  spec.require_paths         = ['lib']
  spec.files                 = Dir['LICENSE.txt', 'README.md', 'lib/**/*']

  spec.add_runtime_dependency 'activesupport', '~> 4.2.0'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'yard', '~> 0.8.7'
end
