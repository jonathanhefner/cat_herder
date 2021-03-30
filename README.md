# cat_herder

Minimal Rails asset pipeline experiment:

* Assets are fingerprinted and copied to `public/assets` in development, just
  like `rails assets:precompile`.  Thus they are served directly, without any
  special routes or middleware.

* ERB assets are evaluated; all other assets are copied verbatim.

* ERB assets can call `asset_path` and all other [`AssetUrlHelper`][] helpers.

  * Currently, `*_url` helpers always return a path instead of a full URL (the
    same as `*_path` helpers).  Assuming these helpers are primarily used for
    import statements (e.g. `@import url(...)`), this shouldn't pose a problem,
    because the browser resolves such partial URLs to the asset host rather than
    the page host.  The benefit of the current implementation is that it
    sidesteps the issue of cache invalidation when `config.asset_host` changes.

* ERB assets can call `render` to render the content of another asset inline.

* ERB assets can call `glob` to iterate over other assets.  Using a given
  pattern, `glob` will search all load paths.  With a combination of `glob` and
  `render`, assets can perform their own bundling.

* ERB assets can call `resolve` to get an absolute path to an asset file.  This
  can be used to pass the asset to an external command, e.g.:

    ```erb
    <%# styles.css.erb %>
    <%= `sass #{resolve "styles.sass"}` %>
    ```

* All calls to `asset_path` / `compute_asset_path`, `render`, and `resolve` will
  add the resulting asset to the current asset's dependencies, so that the
  current asset will be recompiled when any of its dependencies are.

* Partial assets are prefixed with an underscore (like view partials), and are
  not copied to `public/assets` by `rails assets:precompile`.  They can be
  referenced using their logical path without the underscore (like view
  partials).  This allows "private" files, such as raw input files or config
  files, to be placed in any of the asset load paths and be evaluated like other
  assets.  (Calls to `compute_asset_path` that resolve to a partial asset will
  raise an error to prevent broken URLs.)

[`AssetUrlHelper`]: https://api.rubyonrails.org/classes/ActionView/Helpers/AssetUrlHelper.html


## Installation

Add this line to your application's Gemfile:

```ruby
gem "cat_herder"
```

And run:

```bash
$ bundle install
```

Then disable Sprockets, and require *cat_herder* in your `config/application.rb`
file:

```ruby
require "cat_herder/railtie"
```


## Contributing

Run `bin/test` to run the tests.


## License

[MIT License](MIT-LICENSE)
