namespace :luvfoo do
  namespace :i18n do

    desc 'Parse specified files defaults to all files, for unlocalized text. Extract text, write to a yml file'
    task :extract_strings do #TODO: default target = nil

      target_files = view_files
      
      target_files.each do |file|
        scope = get_scope( file )

        strings = parse_file( file )

        #unless strings is nil append to results
      end    

      #dump results to screen or yaml file
    end
        
    desc 'replace strings with keys'
    task :replace_strings do

    end

    def parse_file( file )

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
