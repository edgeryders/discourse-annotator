Administrate::Engine.add_stylesheet('administrate')
Rails.application.config.assets.precompile += %w(administrate.scss)

# Required as otherwise assets are not precompiled.
Rails.application.config.assets.precompile += %w[administrate/application.css]
Rails.application.config.assets.precompile += %w[administrate/application.js]

Rails.application.config.assets.precompile += %w[annotator_store/application.css]
Rails.application.config.assets.precompile += %w[annotator_store/application.js]