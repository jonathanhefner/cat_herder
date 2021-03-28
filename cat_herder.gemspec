require_relative "lib/cat_herder/version"

Gem::Specification.new do |spec|
  spec.name        = "cat_herder"
  spec.version     = CatHerder::VERSION
  spec.authors     = ["Jonathan Hefner"]
  spec.email       = ["jonathan@hefner.pro"]
  spec.homepage    = "https://github.com/jonathanhefner/cat_herder"
  spec.summary     = %q{Minimal Rails asset pipeline experiment}
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.metadata["source_code_uri"] + "/blob/master/CHANGELOG.md"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", ">= 6.1"
end
