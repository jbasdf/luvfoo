desc "Update pot/po files."
task :test do
  puts "Hola, logged_in_user% ()".gsub(/([a-z_]+)% \(\)/, '%{\1}')
end
task :updatepo do
  require 'gettext/utils'
  
  pot_file_name = File.join(RAILS_ROOT, 'po', 'luvfoo.pot')
  File.delete(pot_file_name) if File.exists?(pot_file_name)
#  po_file_name = File.join(RAILS_ROOT, 'po', 'es', 'luvfoo.po')
#  File.delete(po_file_name) if File.exists?(po_file_name)
#  
##  GetText.update_pofiles("luvfoo", Dir.glob("{app,lib,bin}/**/*.{rb,erb,rjs}"), "luvfoo 1.0.0")
  GetText.update_pofiles("luvfoo", Dir.glob("{app/views,app/helpers,app/controllers}/**/*.{html.erb,rb,erb}"), "luvfoo 1.0.0")
#
#  # read the pot file into a string
#  pot_file_text = ''
#  File.open(pot_file_name, "r") { |f|
#      pot_file_text = f.read
#  }
#  # convert the pot file to a format that won't get so badly mangled by google translate
#  msg_id_hash = Hash.new
#  text_to_translate = ''
#  msg_id = 1
#  pot_file_text.scan(/#:[^\n]+\/([^\/]+:[0-9]+)\nmsgid \"(.*)\"/) { |msg|
#      text_to_translate += msg_id.to_s + "\n" + msg[1] + "\n"
#      
#      # id => english text
#      msg_id_hash[msg_id.to_s] = msg[1] 
#      msg_id += 1
#  }
##  puts text_to_translate
#  # use google translate to translate the messages
#  require 'rubygems'
#  require 'google_translate'
#  tr = Google::Translate.new
#  translated_text = tr.translate :from => "en", :to => "es", :text => text_to_translate
#  translated_text = translated_text.gsub('<br />', "\n").gsub(' / ', '/').gsub(" \n ","\n").gsub('% s',' %s').gsub(/([a-z_]+)% \(\)/, '%{\1}') + "\n"
##  puts translated_text
#  
#  # store the translated messages in a hash
#  msg_hash = Hash.new
#  translated_text.scan(/([^\n]+)\n([^\n]+)\n/) { |msg|
#      # english text => translated text
##      puts msg_id_hash[msg[0]] + '=>' + msg[1]
#      msg_hash[msg_id_hash[msg[0]]] = msg[1]
#  }
#  # build the new po file by going through the original and replacing empty strings with the translated  
#  po_file_text = ''     
#  pot_file_text.scan(/(#:[^\n]+\/)([^\/]+:[0-9]+)\nmsgid \"(.*)\"/) { |msg|
#      if msg_hash.has_key?(msg[2])            
#          po_file_text += 
#              '#. Default: ' + msg[2] +
#              "\n" + msg[0] + msg[1] + 
#              "\nmsgid \"" + msg[2] + "\"\n" + 
#              "msgstr \"" + msg_hash[msg[2]] + "\"\n\n"
#      end
#  }
#  # write out the new po file
#  File.open(po_file_name, 'w') {|f| f.write(po_file_text) }

  GetText.create_mofiles(true, "po", "locale")
end

desc "Create mo-files"
task :makemo do
  require 'gettext/utils'
  GetText.create_mofiles(true, "po", "locale")
end