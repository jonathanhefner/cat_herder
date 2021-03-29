# frozen_string_literal: true

require "cat_herder/version"

module CatHerder
  extend ActiveSupport::Autoload

  autoload :AssetNotFound
  autoload :AssetNotPublic
  autoload :Assets
  autoload :Current
  autoload :Helper

  EMPTY_ARRAY = [].freeze
end
