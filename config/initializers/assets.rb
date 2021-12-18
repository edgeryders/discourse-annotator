Administrate::Engine.add_stylesheet('administrate')
Rails.application.config.assets.precompile += %w(administrate.scss)

# Required as otherwise assets are not precompiled. damingo (Github ID), 2020-08-06
Rails.application.config.assets.precompile += %w[administrate/application.css]
Rails.application.config.assets.precompile += %w[administrate/application.js]

Rails.application.config.assets.precompile += %w[discourse-annotator/application.css]
Rails.application.config.assets.precompile += %w[discourse-annotator/application.js]

Rails.application.config.assets.precompile += %w[administrate-field-nested_has_many/application.css]
Rails.application.config.assets.precompile += %w[administrate-field-nested_has_many/application.js]