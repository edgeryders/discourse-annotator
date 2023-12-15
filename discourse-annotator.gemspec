$:.push File.expand_path('../lib', __FILE__)
require 'discourse_annotator/version'

Gem::Specification.new do |spec|
  spec.name           = 'discourse-annotator'
  spec.version        = DiscourseAnnotator::VERSION
  spec.date           = Time.new.getutc.strftime('%Y-%m-%d')
  spec.authors        = ["Job King'ori Maina"]
  spec.email          = ['j@kingori.co']
  # spec.homepage       = 'http://itsmrwave.github.io/discourse_annotator-gem'
  spec.summary        = 'Rails engine to implement a Ruby backend store implementation for Annotator.'
  spec.description    = 'Rails engine to implement a Ruby backend store implementation for Annotator, an open-source JavaScript library to easily add annotation functionality to any webpage.'
  spec.license        = 'MIT'

  spec.files          = Dir['{app,config,db,lib}/**/*', 'CHANGELOG.md', 'CONTRIBUTING.md', 'LICENSE.md', 'Rakefile', 'README.md']
  spec.require_paths  = ['lib']

  spec.required_ruby_version = '>= 1.9.3'

  # Database dependencies
  # spec.add_development_dependency 'mysql2'
  spec.add_development_dependency 'pg'

  # Development dependencies
  spec.add_development_dependency 'appraisal'
  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'factory_girl_rails'
  spec.add_development_dependency 'faker'
  spec.add_development_dependency 'json-schema'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'rubocop'

  # Runtime dependencies
  spec.add_runtime_dependency 'jbuilder'
  # spec.add_runtime_dependency 'rails', '6.1.3.2'
  spec.add_runtime_dependency 'ancestry', '3.2.1'
  # https://github.com/vmg/redcarpet - The safe Markdown parser.
  spec.add_runtime_dependency 'redcarpet'
  # https://github.com/thoughtbot/administrate
  # spec.add_runtime_dependency 'administrate', '0.19.0'
  # NOTE: Frozen to 0.12 as a larger version (tested with 0.16) breaks codes/new and codes/edit pages.
  spec.add_runtime_dependency 'kaminari', '1.2.2'

  spec.add_runtime_dependency 'deep_cloneable', '~> 3.2.0'
  spec.add_runtime_dependency 'activejob'
  spec.add_runtime_dependency 'activejob-status'
end