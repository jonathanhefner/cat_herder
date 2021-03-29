# frozen_string_literal: true

module CatHerder
  class Current < ActiveSupport::CurrentAttributes
    attribute :resolved_paths, :mtime_cache, :dir_children_cache

    def resolved_paths
      super || (self.resolved_paths = {})
    end

    def mtime(path)
      (self.mtime_cache ||= {})[path] ||= File.file?(path) ? File.mtime(path).to_f : Float::NAN
    end

    def dir_children(path)
      (self.dir_children_cache ||= {})[path] ||= File.directory?(path) ? Dir.children(path) : EMPTY_ARRAY
    end
  end
end
