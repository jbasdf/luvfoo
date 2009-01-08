module UrlMethods
    
    require 'open-uri'
    require 'net/http'
    
    # more information about system_timer
    # http://ph7spot.com/articles/system_timer
    begin
      require 'system_timer'
      TimeIt = SystemTimer
    rescue LoadError
      require 'timeout'
      TimeIt = Timeout
    end
    
    def self.get_content(uri, timeout = 10)
        TimeIt.timeout(timeout.seconds) do
            content = open(UrlMethods::fix_http(uri))
        end
    rescue
        nil
    end

    def self.get(uri, headers)
      uri = URI.parse(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      return http.get(uri.path, headers)
    end
        
    def self.post(uri, data, headers)
      uri = URI.parse(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      return http.post(uri.path, data, headers)
    end
    
    def self.fix_http str
        return '' if str.blank?
        str.starts_with?('http') ? str : "http://#{str}"
    end

end