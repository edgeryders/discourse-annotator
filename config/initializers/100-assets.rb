Administrate::Engine.add_stylesheet('administrate')
Rails.application.config.assets.precompile += %w(administrate.scss)


Rails.application.config.assets.precompile << "annotator_store.js"
Rails.application.config.assets.precompile << "annotator_store.css"