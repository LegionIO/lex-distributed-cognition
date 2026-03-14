# frozen_string_literal: true

require_relative 'lib/legion/extensions/distributed_cognition/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-distributed-cognition'
  spec.version       = Legion::Extensions::DistributedCognition::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Distributed Cognition'
  spec.description   = "Hutchins' distributed cognition — cognitive processes spread across " \
                       'agents, artifacts, and environment for brain-modeled agentic AI'
  spec.homepage      = 'https://github.com/LegionIO/lex-distributed-cognition'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']        = spec.homepage
  spec.metadata['source_code_uri']     = 'https://github.com/LegionIO/lex-distributed-cognition'
  spec.metadata['documentation_uri']   = 'https://github.com/LegionIO/lex-distributed-cognition'
  spec.metadata['changelog_uri']       = 'https://github.com/LegionIO/lex-distributed-cognition'
  spec.metadata['bug_tracker_uri']     = 'https://github.com/LegionIO/lex-distributed-cognition/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir.glob('{lib,spec}/**/*') + %w[lex-distributed-cognition.gemspec Gemfile]
  end
  spec.require_paths = ['lib']
end
