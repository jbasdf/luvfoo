require "yaml"

namespace :luvfoo do
  namespace :i18n do

    DEFAULT_LANGUAGE = 'en'

    desc 'Parse specified files defaults to all files, for unlocalized text. Extract text, write to a yml file'
    task :extract_strings do #TODO: default target = nil

      target_files = view_files

      results = Hash.new
      temp = Hash.new
      
      target_files.each do |file|
        scope = get_scope( file )

        strings = parse_file( file )

        #unless strings is nil append to results
        if !strings.nil?
          for string in strings
            results[string] = string
          end
        end

      end    

        yaml_string = YAML::dump( results )
        puts yaml_string unless yaml_string.nil?
    end
        
    desc 'replace strings with keys'
    task :replace_strings do

    end

    def parse_file( file )
      results = []
      File.open( file, 'r').each do | line |
        message = contents( line )
        results << message unless message.nil? 
      end
      return results          
    end

    #FIXME: Clean Up
    def contents( text )
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
    
    def get_scope( file )
      result = file.split('/')
      name = result.last.split('.')[0]
      return result[2..-2].push( name )
    end

     # All view files
    def view_files
      get_files('app/views', '**/*.{erb,builder}')
    end

    def get_files(filter = '**', types='*.{erb,rb}')
      Dir.chdir(RAILS_ROOT)
      Dir.glob("#{filter}/#{types}")
    end   

    
  end
end
