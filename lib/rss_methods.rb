module RssMethods

    include UrlMethods
    
    require 'feed-normalizer'
      
    # uri - url or local file
    def self.get_rss(uri, timeout = 10)        
        content = UrlMethods::get_content(uri, timeout) 
        FeedNormalizer::FeedNormalizer.parse content
    rescue
        nil
    end
    
    def self.auto_detect_rss_url(uri, timeout = 10)
        content = UrlMethods::get_content(uri, timeout)
        if content
            get_feed_path(content.read)
        else
            nil
        end
    end
    
    # from:
    # http://dominiek.com/articles/2007/6/22/detecting-atom-rss-feeds-in-ruby
    # http://blog.99th.st/post/40343167/feed-auto-detect-in-ruby
    # get the feed href from an HTML document
    # for example:
    # ...
    # <link href="/feed/atom.xml" rel="alternate" type="application/atom+xml" />
    # ...
    # => /feed/atom.xml
    # only_detect can force detection of :rss or :atom
    def self.get_feed_path(html, only_detect=nil)
      unless only_detect && only_detect != :atom
        md ||= /<link.*href=['"]*([^\s'"]+)['"]*.*application\/atom\+xml.*>/i.match(html) 
        md ||= /<link.*application\/atom\+xml.*href=['"]*([^\s'"]+)['"]*.*>/i.match(html) 
      end
      unless only_detect && only_detect != :rss
        md ||= /<link.*href=['"]*([^\s'"]+)['"]*.*application\/rss\+xml.*>/i.match(html) 
        md ||= /<link.*application\/rss\+xml.*href=['"]*([^\s'"]+)['"]*.*>/i.match(html) 
      end
      md && md[1]
    end
    
end

  
