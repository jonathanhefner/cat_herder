# frozen_string_literal: true

namespace :cat_herder do
  desc "Compile all assets"
  task :precompile => :environment do
    CatHerder::Assets.precompile
  end
end
