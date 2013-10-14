# mostly from https://github.com/multiscan/middleman-navigation but modified slightly
module Navigation
  class << self
    def registered(app)
      app.helpers HelperMethods
    end

    alias :included :registered
  end

  class Middleman::Sitemap::Resource
    def nonav?
      self.data && self.data[:nonav]
    end
    def hidden?
      self.data && self.data['hidden'] || File.basename(self.path, ".html")[-1]=="_" || File.basename(self.path, ".html")[0]=="_" || File.basename(File.dirname(self.path))[0]=="_"
    end
    def weight
      self.data && self.data['weight'] || 0
    end
  end

  module HelperMethods
    # create a list item containing the link to a given page.
    # If page is the current one, only a span is Class "selected" is added if the page is the current one.
    def menu_item(page, options={:li_class=>''})
      _options = {
        :selected => {:class => "active"},
        :wrapper => "%s"
      }
      options = _options.merge(options)
      mylabel = options[:label] || page.data.title  #this needed to be changed from page.label to page.data.title
      if page==current_page
        options[:li_class] += ' ' + options[:selected][:class]
        link = content_tag :span, mylabel
      else
        link = link_to(mylabel, "/"+page.path)
      end
      link = options[:wrapper] % link
      return content_tag :li, link, :class => options[:li_class].strip
    end

    # create an <ul> list with links to all the childrens of the current page
    def children_nav(options={})
      p = current_page
      return nil if p.nonav?
      c = p.children.delete_if{ |m| m.hidden? }
      return nil if c.empty?
      i = 0;
      menu_content = c.sort{ |a,b| a.weight <=> b.weight }.map{ |cc|
        i += 1
        item_class = (i == 1) ? 'first' : ''
        item_class += ' last' if c.length == i
        options[:li_class] = item_class
        menu_item(cc, options)
      }.join("\n")
      options.delete(:li_class)
      options.delete(:wrapper)
      return content_tag :ul, menu_content, options
    end

    # create an <ul> list with links to all the parent pages down to the root
    def trail_nav()  # removed sep
      p = current_page
      res = Array.new
      res << menu_item(p)
      while p = p.parent
        # removed sep
        res << menu_item(p)
      end
      return res.reverse.join(" ") #removed <ul> tags
    end
  end
end

::Middleman::Extensions.register(:navigation, Navigation) 
