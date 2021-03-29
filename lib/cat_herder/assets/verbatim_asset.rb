# frozen_string_literal: true

require "fileutils"
require "cat_herder/assets/asset"

module CatHerder
  module Assets
    class VerbatimAsset < Asset
      def write
        write_metadata(digest: digest_class.file(source_path).hexdigest)
        FileUtils.cp(source_path, public_file.tap { |file| file.dirname.mkpath }) unless partial?
      end

      def written?
        partial? || super
      end

      def read
        File.read(source_path)
      end
    end
  end
end
