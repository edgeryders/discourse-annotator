Administrate::Engine.add_stylesheet('administrate')
Rails.application.config.assets.precompile += %w(administrate.scss)


Rails.application.config.assets.precompile += %w[administrate/application.css]
Rails.application.config.assets.precompile += %w[administrate/application.js]