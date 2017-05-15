# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
Rails.application.config.assets.precompile += %w( ckeditor/config.js )
Rails.application.config.assets.precompile += %w( ie_lt9.js )
Rails.application.config.assets.precompile += %w( stat_graphs.js )
Rails.application.config.assets.precompile += %w( print.css )
Rails.application.config.assets.precompile += %w( ie.css )

# Loads app/assets/images/custom before app/assets/images
images_path = Rails.application.config.assets.paths
images_path = images_path.insert(0, Rails.root.join("app", "assets", "images", "custom").to_s)
