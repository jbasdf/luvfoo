require "yaml"

namespace :i18n do
  
   LANGUAGE = 'en'

   desc 'Parse view files for gettext calls. Extract text, convert to suggested key value'
   task :extract_gettext_strings do

    target_files = get_file_list

    yaml_string = parse_files( target_files )

    puts yaml_string unless yaml_string.nil?
  end

  def parse_files( files )
    results = Hash.new
    
    files.each do |file|
      scope = get_scope( file )

      strings = parse_file( file )

      if !strings.nil? and !strings.empty?
        string_hash = Hash.new
     
        for string in strings
          string_hash[string] = string
        end

        for token in scope.reverse
          temp = string_hash
          string_hash = Hash.new
          string_hash[ token ] = temp
        end
        
        results = hash_merge( results, string_hash )
      end      
    end

    lang_hash = Hash.new

    lang_hash[LANGUAGE] = results

    yaml_string = YAML::dump( lang_hash )
  end

  def get_scope( file )
    result = file.split('/')
    name = result.last.split('.')[0]
    return result[2..-2].push( name )
  end
  
  def parse_file( file )
    results = []
    File.open( file, 'r').each do | line |
      message = gettext_contents( line )
      results << message unless message.nil? 
    end
    return results          
  end

  def suggested_key( string )
    
  end
  
  def hash_merge( first, second )
    return second if second.empty?

    second.keys.each do |key|
      if second[key].is_a?(Hash) and first[key].is_a?(Hash)
        first[key] = hash_merge( first[key], second[key] )
        next
      end

      first[key] = second[key]
    end

    first      
  end
  
  
  #FIXME: Clean Up
  #FIXME: escape chars
  #FIXME: check for proper parsing
  def gettext_contents( text )
    single_quotes = /\_\(\'([^']*)\'.*\)/.match(text)
    double_quotes = /\_\(\"([^"]*)\".*\)/.match(text)

    if single_quotes
      return single_quotes[1]
    elsif double_quotes
      return double_quotes[1]
    else
      return nil
    end
  end

  def get_file_list
    view_files
    controller_files
    model_files
    helper_files
  end

  def view_files
    get_files('app/views', '**/*.{erb,builder}')
  end

  def controller_files
    get_files('app/controllers', '**/*.{erb,builder}')
  end

  def model_files
    get_files('app/models', '**/*.{erb,builder}')
  end

  def helper_files
    get_files('app/helpers', '**/*.{erb,builder}')
  end


  def get_files(filter = '**', types='*.{erb,rb}')
    Dir.chdir(RAILS_ROOT)
    Dir.glob("#{filter}/#{types}")
  end   

end
