# frozen_string_literal: true

require "rails"
require "cat_herder"

module CatHerder
  class Railtie < ::Rails::Railtie
    config.assets = ActiveSupport::OrderedOptions.new

    initializer "assets.configure" do |app|
      Assets.load_paths = [
        *app.paths["app/assets"].existent_directories,
        *app.paths["lib/assets"].existent_directories,
        *app.paths["vendor/assets"].existent_directories,
        *app.config.assets.paths,
      ]
      Assets.public_subpath = app.config.assets.prefix.delete_prefix("/") if app.config.assets.prefix
      Assets.cache_store = app.config.assets.cache_store || [:file_store, app.root.join("tmp/assets.cache")]
      Assets.precompiled = app.config.assets.compile == false
    end

    server do
      if Assets.precompiled?
        Assets.precompiled_asset_paths # warm up
      else
        Assets.clean
      end
    end

    ActiveSupport.on_load(:action_view) do
      include Helper
    end

    rake_tasks do
      load "tasks/cat_herder_tasks.rake"
    end
  end
end
