Administrate::Engine.add_stylesheet('administrate')
Rails.application.config.assets.precompile += %w(administrate.scss)



Rails.application.config.assets.paths << root.join("app", "assets", "javascripts", "annotator_store")
Rails.application.config.assets.paths << root.join("app", "assets", "stylesheets", "annotator_store")


Rails.application.config.assets.precompile << "application.js"
Rails.application.config.assets.precompile << "application.css"