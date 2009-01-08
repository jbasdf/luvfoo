`acts_as_solr` Rails plugin
======
This plugin adds full text search capabilities and many other nifty features from Apache's [Solr](http://lucene.apache.org/solr/) to any Rails model.
It was based on the first draft by Erik Hatcher.

Current Release
======
The current stable release is v0.9 and was released on 06-18-2007.

Changes
======
Please refer to the CHANGE_LOG

Installation
======

Requirements
------
* Java Runtime Environment(JRE) 1.5 aka 5.0 [http://www.java.com/en/download/index.jsp](http://www.java.com/en/download/index.jsp)

Basic Usage
======
<pre><code>
# Just include the line below to any of your ActiveRecord models:
  acts_as_solr

# Or if you want, you can specify only the fields that should be indexed:
  acts_as_solr :fields => [:name, :author]

# Then to find instances of your model, just do:
  Model.find_by_solr(query) #query is a string representing your query

# Please see ActsAsSolr::ActsMethods for a complete info

</code></pre>


`acts_as_solr` in your tests
======
To test code that uses `acts_as_solr` you must start a Solr server for the test environment. You can do that with `rake solr:start RAILS_ENV=test`

However, if you would like to mock out Solr calls so that a Solr server is not needed (and your tests will run much faster), just add this to your `test_helper.rb` or similar:

<pre><code>
class ActsAsSolr::Post
  def self.execute(request)
    true
  end
end
</pre></code>

([via](http://www.subelsky.com/2007/10/actsassolr-capistranhttpwwwbloggercomim.html#c1646308013209805416))

Authors
======
Erik Hatcher: First draft<br>
Thiago Jackiw: Current developer (tjackiw at gmail dot com)

Release Information
======
Released under the MIT license.

More info
======
[http://acts-as-solr.railsfreaks.com](http://acts-as-solr.railsfreaks.com)