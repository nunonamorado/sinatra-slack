# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sinatra/slack/version'

Gem::Specification.new do |spec|
  spec.name          = 'sinatra-slack'
  spec.version       = Sinatra::Slack::VERSION
  spec.authors       = ['Nuno Namorado']
  spec.email         = ['n.namorado@gmail.com']

  spec.summary       = 'Create Slack apps with a simple Sinatra specific DSL'
  spec.homepage      = 'https://github.com/nunonamorado/sinatra-slack'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.glob('lib/**/*') + %w[CODE_OF_CONDUCT.md LICENSE.txt README.md]
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'

  spec.add_runtime_dependency 'async_sinatra', '~> 1.3', '>= 1.3.0'
  spec.add_runtime_dependency 'httparty', '~> 0.16', '>= 0.16.4'
  spec.add_runtime_dependency 'mustermann', '~> 1.0', '>= 1.0.3'
  spec.add_runtime_dependency 'sinatra', '~> 2.0', '>= 2.0.5'
  spec.add_runtime_dependency 'thin', '~> 1.7', '>= 1.7.2'
end
