module QuickLinks
  require 'redcarpet'

  class << self
    def registered(app)
      app.helpers HelperMethods
    end

    alias :included :registered
  end

  module HelperMethods
    def quick_links()
      links = []
      page_src = File.read(current_page.source_file)
      sections = page_src.scan /\n\#{2,3}[^#]+\#{2,3}\n/

      markdown = ''

      sections.each do |s|
        
        next if s.match(/id=['"](.+)['"]/).nil? or s.match(/<\/a>([^#.]+)\#{2,3}/).nil?

        anchor_name = s.match(/id=['"](.+)['"]/)[1]
        title = s.match(/<\/a>([^#.]+)\#{2,3}/)[1].strip!
        indent = (s.count('#') / 2) - 2

        markdown << '  ' * indent
        markdown << "* [#{title}](##{anchor_name})\n"

      end
      
      md = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
      result = md.render(markdown)
      "<div class=\"quick-links\">#{result}</div>"
    end
  end
end

::Middleman::Extensions.register(:quicklinks, QuickLinks) 
