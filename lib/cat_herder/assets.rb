# frozen_string_literal: true

require "pathname"
require "active_support/core_ext/enumerable"

module CatHerder
  module Assets
    extend ActiveSupport::Autoload

    autoload :ErbAsset
    autoload :VerbatimAsset

    mattr_accessor :load_paths, default: []
    mattr_accessor :public_subpath, default: "assets"
    mattr_accessor :cache_store
    mattr_accessor :precompiled, default: false
    singleton_class.alias_method :precompiled?, :precompiled

    class << self
      def cache
        @cache ||= ActiveSupport::Cache.lookup_store(*cache_store)
      end

      def public_path
        @public_path ||= Rails.public_path.join(public_subpath)
      end

      def public_files
        public_path.glob("**/*").select(&:file?)
      end

      def public_file_logical_path(public_file)
        public_file.dirname.relative_path_from(public_path).to_s
      end

      def resolve_logical_path(logical_path)
        Current.resolved_paths[logical_path] ||= begin
          logical_dirname, logical_basename = File.split(logical_path)
          basename_pattern = /\A_?#{Regexp.escape logical_basename}(?:\.erb)?\z/
          load_paths.find do |load_path|
            dirname = File.expand_path(logical_dirname, load_path)
            basename = Current.dir_children(dirname).find { |name| basename_pattern.match?(name) }
            break File.join(dirname, basename) if basename
          end
        end
      end

      def [](logical_path)
        source_path = resolve_logical_path(logical_path) or raise AssetNotFound, logical_path
        (@assets ||= {})[source_path] ||= (source_path.end_with?(".erb") ? ErbAsset : VerbatimAsset).new(logical_path, source_path)
      end

      def glob(*logical_patterns, &block)
        logical_patterns.map! { |pattern| "#{pattern}{,.erb}" }
        load_paths.flat_map { |load_path| Dir.glob(*logical_patterns, base: load_path) }.
          each { |path| path.sub!(%r"_?([^/]+?)(?:\.erb)?\z", '\1') }.uniq.
          tap { |logical_paths| logical_paths.each(&block) if block }
      end

      def precompile
        public_path.rmtree if public_path.exist?
        glob("**/[^_]*") { |logical_path| self[logical_path].compile }
        @assets&.each_value { |asset| asset.public_file.dirname.rmtree if asset.partial? && asset.public_file.exist? }
        cache.clear
      end

      def precompiled_asset_paths
        @precompiled_asset_paths ||= public_files.index_by { |file| public_file_logical_path(file) }.
          transform_values! { |file| "/#{file.relative_path_from(Rails.public_path)}" }
      end

      def precompiled_asset_path(logical_path)
        precompiled_asset_paths[logical_path] or raise AssetNotFound, logical_path
      end

      def clean
        public_files.each do |file|
          logical_path = public_file_logical_path(file)
          file.delete unless resolve_logical_path(logical_path) && file == self[logical_path].public_file
        end
      end
    end
  end
end
