# The following code is a work-around for the Flash 8 bug that prevents our multiple file uploader
# from sending the _session_id.  Here, we hack the Session#initialize method and force the session_id
# to load from the query string via the request uri. (Tested on Lighttpd, Mongrel, Apache)

# hacks for swfupload + cookie store to work
# see http://blog.airbladesoftware.com/2007/8/8/uploading-files-with-swfupload
#
# also need to put
# session :cookie_only => false, :only => :create
# into the controller where the files are being uploaded (change method as appropriate)

class CGI::Session
  alias original_initialize initialize
  def initialize(request, option = {})
    session_key = option['session_key'] || '_session_id'
    query_string = if (qs = request.env_table["QUERY_STRING"]) and qs != ""
      qs
    elsif (ru = request.env_table["REQUEST_URI"][0..-1]).include?("?")
      ru[(ru.index("?") + 1)..-1]
    end
    if query_string and query_string.include?(session_key)
      option['session_id'] = query_string.scan(/#{session_key}=(.*?)(&.*?)*$/).flatten.first
    end
    original_initialize(request, option)
  end
end