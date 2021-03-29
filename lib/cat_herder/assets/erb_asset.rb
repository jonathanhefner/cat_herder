# frozen_string_literal: true

require "action_view/helpers/asset_url_helper"
require "cat_herder/assets/asset"

module CatHerder
  module Assets
    class ErbAsset < Asset
      def write
        result, dependencies = evaluate_erb
        write_metadata(digest: digest_class.hexdigest(result), dependencies: dependencies)
        public_file.tap { |file| file.dirname.mkpath }.write(result)
      end

      def read
        public_file.read
      end

      private
        def evaluate_erb
          ruby = Assets.cache.fetch([self, "ruby"], version: source_mtime) do
            require "erubi"
            Erubi::Engine.new(File.read(source_path), filename: source_path).src
          end
          context = ErbContext.new(logical_path)
          [context.instance_eval(ruby), context._dependencies]
        end

        class ErbContext
          include ActionView::Helpers::AssetUrlHelper

          attr_reader :_dependencies

          def initialize(logical_path)
            @_logical_path = logical_path
            @_dependencies = []
          end

          def compute_asset_path(logical_path, *)
            _dependency(logical_path).asset_path
          end

          def resolve(logical_path)
            _dependency(logical_path).source_path
          end

          def render(logical_path)
            _dependency(logical_path).render
          end

          def glob(*logical_patterns, &block)
            Assets.glob(*logical_patterns.map { |pattern| _expand_logical_path(pattern) }, &block)
          end

          private
            def _dependency(logical_path)
              dependency = Assets[_expand_logical_path(logical_path)]
              @_dependencies << dependency unless @_dependencies.include?(dependency)
              dependency
            end

            def _expand_logical_path(logical_path)
              logical_path.start_with?("./", "../") ? Pathname(@_logical_path).dirname.join(logical_path).to_s : logical_path
            end
        end
    end
  end
end
