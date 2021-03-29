# frozen_string_literal: true

module CatHerder
  module Helper
    def compute_asset_path(logical_path, options = {})
      Assets.precompiled? ? Assets.precompiled_asset_path(logical_path) : Assets[logical_path].asset_path
    end
  end
end
