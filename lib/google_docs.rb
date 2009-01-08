require 'net/http'
require 'uri'

module GoogleDocs
  protected

  DOCUMENT = 1
  SPREADSHEET = 2
  PRESENTATION = 3

  def is_google_doc address
    is_gdoc = !address.nil? && address.match(/http:\/\/(spreadsheets|docs).google.com/)
    return is_gdoc
  end
  
  def get_doc_id address
    id_match = address.match(/(doc)?id=([^\&]+)/)
    id_match && id_match[2] ? id_match[2] : ''
  end
  
  def is_published address
    return true if (address[23,8] == 'View?id=' || address[23,10] == 'View?docid=')

    html = download_published_doc(address)
    
    case get_document_type(address)
      when DOCUMENT
        return html != '' 
      when SPREADSHEET
        return !html.include?('isn\'t published') 
      when PRESENTATION
        return html != ''
    end
    return false
  end
  
  def get_document_type address
    return PRESENTATION if (address[0,35] == 'http://docs.google.com/Presentation') 
    return DOCUMENT if (address[0,23] == 'http://docs.google.com/') 
    return SPREADSHEET if (address[0,31] == 'http://spreadsheets.google.com/')
  end
  
  def get_html address
    content = download_published_doc(address)
    match = content.match(/(<style type="text\/css">.*)\/\* end ui edited css \*\/.*(<div id="doc-contents">.*)<div id="google-view-footer">/m)
    match ? match[1] + '</style>' + match[2] : content
  end
  
  private
  
  def get_publish_uri address
    uri = URI.parse(address)
    case get_document_type(address)
      when DOCUMENT
        uri.path = '/View' if uri.path == '/Doc'
      when SPREADSHEET
        uri.path = '/pub' if uri.path == '/ccc'
      when PRESENTATION
        if uri.path == '/Presentation' || uri.path == '/PresentationEditor'
          uri.path = '/Present'
          uri.query += '&skipauth=true'
        end
    end
    return uri
  rescue 
    nil
  end
  
  def download uri
    response = Net::HTTP.get_response(uri)
    return (response && response.code != '302' && response.body) ? response.body : ''
  rescue
    return ''
  end
  
  def download_published_doc address
    download(get_publish_uri(address))
  end
  
end
