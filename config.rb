###
# Compass
###

# Susy grids in Compass
# First: gem install susy
# require 'susy'

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", :layout => false
#
# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy (fake) files
# page "/this-page-has-no-template.html", :proxy => "/template-file.html" do
#   @which_fake_page = "Rendering a fake page with a variable"
# end

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

require 'navigation'
require 'quicklinks'

set :markdown_engine, :redcarpet
set :markdown, :layout_engine => :erb,
               :tables => true,
               :autolink => true,
               :smartypants => true,
               :fenced_code_blocks => true

set :css_dir, 'stylesheets'

set :js_dir, 'javascripts'

set :images_dir, 'images'

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript

  # Enable cache buster
  # activate :cache_buster

  # Use relative URLs
  activate :relative_assets
  set :relative_links, true

  # Compress PNGs after build
  # First: gem install middleman-smusher
  # require "middleman-smusher"
  # activate :smusher

  # Or use a different image path
  # set :http_path, "/Content/images/"
end

# For syntax highlighting .. middleman-syntax
activate :syntax

# For navigation breadcrumbs
activate :navigation

# For generated intra-page links
activate :quicklinks

# For live reload
# activate :livereload

helpers do
  class Middleman::Sitemap::Page
    def banner_url
      p= "/" + app.images_dir + "/banner/" + self.path.gsub(/\.html$/, ".jpg")
      unless File.exists?(app.source_dir+p)
        p = self.parent ? self.parent.banner_url : "/" + app.images_dir + "/banner/default.jpg"
      end
      return p
    end

    def label
      self.data && self.data['menu_title'] || self.parent.nil? ? "home" : File.basename(self.directory_index? ? File.dirname(self.path) : self.path, ".html").gsub("_", " ")
    end
  end

  def banner_img(opts={:width=>700, :height=>120})
    image_tag current_page.banner_url, opts
  end

  # Returns all pages under a certain directory.
  def sub_pages(dir)
    sitemap.resources.select do |resource|
      resource.path.start_with?(dir)
    end
  end 

end
