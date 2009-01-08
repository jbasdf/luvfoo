require "#{File.dirname(__FILE__)}/../test_helper"

# from:
# http://dominiek.com/articles/2007/6/22/detecting-atom-rss-feeds-in-ruby
class RssMethodsTest < ActionController::IntegrationTest

    def test_auto_detect_rss_url
        return # uncomment me to test HTTP fetching

        # test mephisto
        feed_url = RssMethods.auto_detect_rss_url('http://blog.dominiek.com/')
        assert_equal('http://blog.dominiek.com/feed/atom.xml', feed_url)

        # test wordpress
        feed_url = RssMethods.auto_detect_rss_url('http://www.justinball.com')
        assert_equal('http://www.justinball.com/feed/', feed_url)

        # test non conventional port
        feed_url = RssMethods.auto_detect_rss_url('http://blog.dominiek.com:8000/')
        assert_equal('http://blog.dominiek.com:8000/feed/atom.xml', feed_url)

        # test only_detect rss/atom on flickr
        feed_url = RssMethods.auto_detect_rss_url('http://www.flickr.com/photos/dominiekterheide/', :atom)
        assert_equal('http://api.flickr.com/services/feeds/photos_public.gne?id=71386598@N00&amp;lang=en-us&format=atom', feed_url)
        feed_url = RssMethods.auto_detect_rss_url('http://www.flickr.com/photos/dominiekterheide/', :rss)
        assert_equal('http://api.flickr.com/services/feeds/photos_public.gne?id=71386598@N00&amp;lang=en-us&format=rss_200', feed_url)

        # make sure that feeds return themselves
        feed_url = RssMethods.auto_detect_rss_url('http://blog.dominiek.com/feed/atom.xml')
        assert_equal('http://blog.dominiek.com/feed/atom.xml', feed_url)
        feed_url = RssMethods.auto_detect_rss_url('http://digigen.nl/feed/')
        assert_equal('http://digigen.nl/feed/', feed_url)
    end

    def test_get_feed_path
        body = []
        body << ' <html>'
        body << '  <head>'
        body << '   <link href="/super.css" rel="alternate" type="text/css"/>'
        body << '   <link href="/feed/atom.xml" rel="alternate" type="application/atom+xml" />'
        body << '  </head>'
        body << ' </html>'

        # Mephisto
        feed_path = RssMethods.get_feed_path(body.join("\n"))
        assert_equal('/feed/atom.xml', feed_path)
        body[3] = '   <link href=\'/feed/atom.xml\' rel="alternate" type="application/atom+xml" />'
        feed_path = RssMethods.get_feed_path(body.join("\n"))
        assert_equal('/feed/atom.xml', feed_path)

        # FlickR
        body[3] = '<link rel="alternate" type="application/atom+xml" title="Flickr: Photos from dominiekth Atom feed" href="http://api.flickr.com/services/feeds/photos_public.gne?id=71386598@N00&amp;lang=en-us&format=atom">'
        feed_path = RssMethods.get_feed_path(body.join("\n"))
        assert_equal('http://api.flickr.com/services/feeds/photos_public.gne?id=71386598@N00&amp;lang=en-us&format=atom', feed_path)
        body[4] = '<link rel="alternate"   type="application/rss+xml" title="Flickr: Photos from dominiekth RSS feed" href="http://api.flickr.com/services/feeds/photos_public.gne?id=71386598@N00&amp;lang=en-us&format=rss_200">'
        feed_path = RssMethods.get_feed_path(body.join("\n"))
        assert_equal('http://api.flickr.com/services/feeds/photos_public.gne?id=71386598@N00&amp;lang=en-us&format=atom', feed_path)
        feed_path = RssMethods.get_feed_path(body.join("\n"), :rss)
        assert_equal('http://api.flickr.com/services/feeds/photos_public.gne?id=71386598@N00&amp;lang=en-us&format=rss_200', feed_path)

        # Wordpress
        body[3] = '<link rel="alternate" type="application/rss+xml" title="Digigen RSS Feed" href="http://digigen.nl/feed/" />'
        body[4] = ' </head>'
        feed_path = RssMethods.get_feed_path(body.join("\n"), :atom)
        assert_equal(nil, feed_path)
        feed_path = RssMethods.get_feed_path(body.join("\n"), :rss)
        assert_equal('http://digigen.nl/feed/', feed_path)
    end

end