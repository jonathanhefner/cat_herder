# frozen_string_literal: true

module CatHerder
  class AssetNotFound < StandardError
    def initialize(logical_path)
      super("Could not find asset #{logical_path.inspect}.")
    end
  end
end
