#How to install Luvfoo#

1. Start by making sure your RubyGems are version 1.2.0 or greater:

        sudo gem update --system

2. Add the Github repository to your gems:

        sudo gem sources -a http://gems.github.com

3. Luvfoo runs on Ruby on Rails, so first you need to get Rails running. In order to do that, download Rails from the [Ruby on Rails site] or install though gems:

        sudo gem install rails -v=2.1.1

4. Copy config/database.yml.example to config/database.yml and edit it to reflect the database names you would like to 
   use.

5. Copy config/global_config.yml.example to config/global_config.yml and edit it to reflect your application 
   customized configurations.

6. Copy config/environments/production.rb.example to config/environments/production.rb and edit `asset_host` in order 
   to reflects the name of the production asset server.

7. Configure your mail settings inside of production.rb ie:

    ActionMailer::Base.delivery_method = :smtp
    ActionMailer::Base.smtp_settings = {
      :address => "mail.luvfoo.com",
      :port => 25,
      :domain => "luvfoo.com",
      :authentication => :login,
      :user_name => "demo@luvfoo.com",
      :password => "sweet"
    }

8. You will need to install some 3th party softwares. Above, there is the command to install them in Ubuntu and other 
   Debian-based Linux distribuitions:

        sudo apt-get install gettext
        
              or in OSX 10.5
              
        sudo gem install gettext

   **Note**: on Ubuntu you can use sudo gem install gettext -v=1.93.0. The 2.0 version will not work. It throws No such file "gettext/rails".

9. luvfoo currently has a few dependencies that prevent a basic rake from running. We need to install the following:

        sudo gem install mini_magick
        sudo gem install hpricot
        sudo gem install gcnovus-avatar
        
   **Note**: To get hpricot working, do: sudo apt-get install ruby1.8-dev
    
    make sure you have gcc: 
    
    sudo apt-get install gcc
    sudo apt-get install libmagick9-dev
    
   **Note**: You also need to install Imagemagick and RMagick. Get the latest gz file from imagemaick.org and untar to a directory, then run:
    sudo ./configure --enable-openmp=no --disable-static --with-modules --without-perl --without-threads --without-magick-plus-plus --with-quantum-depth=8  --with-gs-font-dir=$FONTS
    sudo make
    sudo make install
    set LD_LIBRARY_PATH=/usr/local/lib (that is where imagemagick so files are installed)
    ldconfig
    
    Make sure that Imagemagick is installed properly by running:
    /usr/local/bin/convert logo logo.gif
    
    Then you can run: gem install rmagick
    check if rmagick is installed correctly by:
    irb -rubygems -r RMagick. If you get a prompt then you are ok.
        
    Now you should be able to run rails built in rake tasks to include the rest.
        
        sudo rake gems:install
    
    Install the following additional gems - these are required while testing the application using 'rake test' or 'autotest':
    
    	sudo gem install thoughtbot-factory_girl 
	sudo gem install zentest
	sudo gem install thoughtbot-shoulda
	sudo gem install redgreen

10. Run the following commands to create the database, the tables and then populate them with default data:

        rake db:create
        rake db:schema:load
    **Note**: if db create fails, create it using mysql command window. Use utf8 charset.
        
11. We need to get solr running before you can populate the database:

        mkdir tmp/pids
        mkdir tmp/pids/solr
        rake solr:start

12. Now we can populate the database:

        rake luvfoo:db:populate

13. Start the server with:

        script/server

14. Go to http://localhost:3000/ and login with username `admin` and password `admin`. Change it ASAP.

15. Have fun with *Luvfoo*!

  [Ruby on Rails site]: http://www.rubyonrails.com/  "Ruby on Rails official site"

