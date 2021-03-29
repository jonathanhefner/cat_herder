# frozen_string_literal: true

module CatHerder
  module Assets
    class Asset
      attr_reader :logical_path, :source_path, :partial
      alias :partial? :partial

      def initialize(logical_path, source_path)
        @logical_path = logical_path
        @source_path = source_path
        @partial = File.basename(source_path).start_with?("_")
        @metadata = Assets.cache.read([self, "metadata"]) || {}
      end

      def cache_key
        source_path.delete_prefix(Rails.root.to_s)
      end

      def digest_class
        ActiveSupport::Digest.hash_digest_class
      end

      def digest
        @metadata[:digest]
      end

      def dependencies
        @metadata[:dependencies]&.map { |logical_path| Assets[logical_path] } || EMPTY_ARRAY
      end

      def dependency_digests
        @metadata[:dependency_digests] || EMPTY_ARRAY
      end

      def mtime
        @metadata[:mtime] || Float::NAN
      end

      def source_mtime
        Current.mtime(source_path)
      end

      def stale?
        mtime != source_mtime || dependency_digests != dependencies.map(&:digest) || dependencies.any?(&:stale?)
      end

      def public_subpath
        File.join(Assets.public_subpath, logical_path, "#{digest}#{File.extname(logical_path)}")
      end

      def public_file
        Rails.public_path.join(public_subpath)
      end

      def written?
        Current.mtime(public_file.to_s) > 0
      end

      def compile
        write if !written? || stale?
      end

      def write_metadata(digest:, dependencies: nil)
        @metadata = {
          mtime: source_mtime,
          digest: digest,
          dependencies: dependencies&.map(&:logical_path),
          dependency_digests: dependencies&.map(&:digest),
        }
        Assets.cache.write([self, "metadata"], @metadata)
      end

      def asset_path
        raise AssetNotPublic, self if partial?
        compile
        File.join("/", public_subpath)
      end

      def render
        compile
        read
      end

      def write; raise NotImplementedError; end
      def read; raise NotImplementedError; end
    end
  end
end
