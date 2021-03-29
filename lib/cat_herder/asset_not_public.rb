# frozen_string_literal: true

module CatHerder
  class AssetNotPublic < StandardError
    def initialize(asset)
      super("Asset #{asset.logical_path.inspect} (#{asset.source_path.inspect}) does not expose a public path.")
    end
  end
end
