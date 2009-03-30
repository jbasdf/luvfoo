#LUVFOO SETUP ON WINDOWS#

This tutorial explains how to get Luvfoo going on your local Windows machine and deploy it to a Linux server. It assumes that you have a technical background, have never developed with Ruby on Rails, and are starting from ground zero on your machine. To develop and deploy Luvfoo you:


##Install##

    * Command Prompt Here
    
    * Ruby (language), Ruby on Rails (web application framework), and Ruby Gems (package manager)
    
    * Aptana Studio and RadRails (Ruby on Rails Development Environment)
    
    * MySQL (database)
    
    * Git (version control system)
    
    * Capistrano (deployment tool)
    
    * PuTTY (SSH client)
    
    * GetText for Windows (translation file utilities) 
    

##Develop##

    * Retrieve Luvfoo from git hub
         
    * Install RMagick
    
    * Install Luvfoo gem dependencies
    
    * Configure Luvfoo
    
    * Set up databases for Luvfoo
    
    * Run Luvfoo on your computer
    
    * Merge the latest Luvfoo code from the master branch into another branch
    
    * Run the Luvfoo tests
    
    * Set up an Aptana Studio project for working on Luvfoo
    
    * Update translation files
    
    * Commit changes to a Luvfoo branch ssss
    
    * Push Luvfoo changes to github
    

##Deploy to a Linux server##
    
    * Generate a private / public key pair and copy your public key to the remote server
         
    * Deploy Luvfoo to the remote server
         
    * Diagnose and fix problems on the server
         
    * Restart mongrel 


For additonal support, consider accessing or joining the [Luvfoo Google group](http://groups.google.com/group/luvfoo) or visiting the **luvfoo irc channel**. To see what the Luvfoo core developers are working on and planning, see the [Trac instance set up for Luvfoo](http://twb1.enpraxis.net/projects/twbtools/report/1).


##Install##

###Command Prompt###

You are going to be doing a lot of things from the command prompt. Setting up [Command Prompt Here](http://www.fileformat.info/tip/microsoft/cmd_prompt_here.htm) makes it so you can open a command prompt in the directory that you are viewing in Windows Explorer.

   1. Open Windows Explorer
   2. Choose Tools - Folder Options...
   3. Switch to the File Types tab
   4. Select Folder from the list and press the Advanced button.
   5. Choose New
   6. Give it a nice name like "Command Prompt Here" and the application c:\windows\system32\cmd.exe /K cd "%1"
   7. OK, OK and OK to save it. 

Credits: I copied this verbatim from [FileFormat.info](http://www.fileformat.info/tip/microsoft/cmd_prompt_here.htm).


###Ruby (language), Ruby on Rails (web application framework), and Ruby Gems (package manager)###

[Ruby](http://www.ruby-lang.org/en/) is the flexible and fun :-) programming language from Japan made popular by the productive [Ruby on Rails](http://rubyonrails.org/) web application framework. Third party Ruby libraries are called Gems. Ruby Gems is the standard Ruby package manager, similar to apt-get, emerge, and other OS package managers.

Luvfoo is a web application written on top of the Ruby on Rails framework. Follow these [instructions on installing Ruby, Ruby on Rails, and Ruby Gems](http://rubyonrails.org/download) to get started. As of 10/3/08 the following versions are recommended: [Ruby 1.8.6-26](http://rubyforge.org/frs/download.php/29263/ruby186-26.exe), [Ruby Gems 1.3.0](http://rubyforge.org/frs/download.php/43986/rubygems-1.3.0.zip), and Ruby on Rails 2.1.1.

   1. Download and run the [Ruby 1.8.6-26 install](http://rubyforge.org/frs/download.php/29263/ruby186-26.exe)
   2. Download and extract [Ruby Gems 1.3.0](http://rubyforge.org/frs/download.php/43986/rubygems-1.3.0.zip), then 
      open a command prompt to the folder you extracted it to and run ruby setup.rb
   3. Install Rails
      gem install -v=2.1.1 rails
      Specifying the -v=2.1.1 option will ensure you get version 2.1.1. of rails which is the latest version it has been tested on. It should work on later versions, but you would need to change the following line in config/environment.rb
      RAILS_GEM_VERSION = '2.1.1'
   4. Add github to the list of gem sources (some of the gems that Luvfoo uses are hosted on github):
      gem sources -a http://gems.github.com


###Install Aptana Studio and RadRails (Ruby on Rails Development Environment)###

The core Ruby on Rails developers develop on Macs and shun us Windows users :-) They swear by (and point business to) a commercial editor called [Textmate](http://macromates.com/). On Windows, the awesome open source [Eclipse](http://www.eclipse.org/) IDE is my favorite. [Aptana](http://www.aptana.com/) has developed a variant of Eclipse (Aptana Studio) and Ruby on Rails plugins for Aptana Studio and Eclipse that make things easier. [Download Aptana Studio](http://www.aptana.com/studio/download/) (117 MB) or go with your favorite editor (please don't say Notepad :-).

   1. Download and install [Aptana Studio 1.2](http://www.aptana.com/studio/download/) (117 MB)
   2. Add the RadRails plugin (34 MB) to Aptana Studio by following the instructions at Help > Open My Aptana > Plugins > Aptana RadRails.
   

###Install MySQL (Database)###

Luvfoo utilizes a database on the back end. Development of Luvfoo has used [MySQL, the world's most popular open source database](http://www.mysql.com/), but it should be use other databases such as Postgres. Download and install [MySQL Community Server edition](http://dev.mysql.com/downloads/mysql/5.0.html#win32).

Download and install [MySQL Community Server edition (Windows Essentials x86)](http://dev.mysql.com/downloads/mysql/5.0.html#win32).

Scroll down and click ####No thanks, just take me to the downloads!#### if you don't want to register.

I used all of the default options when I installed MySQL except on the page that prompted me to "Please select the default character set". Here I chose "Best support for multi-lingualism" (UTF8). If you only ever are going to have English users and content, you can stick with "Standard Character Set" (latin1).

I also unchecked the "Modify Security Settings" this leaves the root user's password blank. This is probably ok for your development machine because it is also configured to only accept connections from itself (not other machines).

This sets it the MySQL server up to run on port 3306.


###Install Git (version control system)###

[Git](http://git.or.cz/) is a version control system like CVS or SVN (but better). Luvfoo developers use it to coordinate work. The [definitive source for Luvfoo](http://github.com/jbasdf/luvfoo/tree/master) is hosted at [github](http://github.com/) (an awesome free service!).

Follow [Kyle's Cordes instructions on installing Git on Windows](http://kylecordes.com/2008/04/30/git-windows-go/) or the [shorter description on github](http://github.com/guides/using-git-and-github-for-the-windows-for-newbies) to get started with Git.

Download and run [the msysgit installer](http://code.google.com/p/msysgit/downloads/list) (I tested with [Git-1.6.0.2-preview20080923.exe](http://msysgit.googlecode.com/files/Git-1.6.0.2-preview20080923.exe)).

I used the default options except on the page titled "Adjusting your PATH environment", I chose run Git and included Unix tools from the command prompt.


###Install Capistrano (Deployment tool)###

Deploying Luvfoo to a Linux server can take an hour or more when done by hand, seconds when done using [Jamis Buck's Capistrano](http://www.capify.org/). Jamis, you are the man! As stated in the [Capistrano Download Instructions](http://www.capify.org/download), now that you have Ruby Gems installed, downloading and installing Capistrano is as easy as typing:

gem install capistrano


###Install PuTTY (SSH Client)###

The standard way to talk to a Linux box is using [SSH](http://en.wikipedia.org/wiki/Secure_Shell). Download and install [PuTTY](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html) (a Windows SSH client) to prepare to connect. While you are at it, you may want to grab pageant, a utility that will save you from having to retype your ssh password repeatedly.


###Install GetText for Windows###

GetText is a GNU translation utility used by Luvfoo to support translation into other languages. Download and install [GetText for Windows](http://gnuwin32.sourceforge.net/packages/gettext.htm), and the bundled utilities, so that you will have [msgmerge](http://gd.tuwien.ac.at/linuxcommand.org/man_pages/msgmerge1.html) for merging updated translation files into existing ones. 


###Install RMagick###

[RMagick](http://rmagick.rubyforge.org/) is an image manipulation library that Luvfoo uses. Use these instructions to [Download and Install on Windows](http://rmagick.rubyforge.org/install-faq.html#win):

   1. Download the [rmagick-win32 gem](http://rubyforge.org/frs/download.php/43232/RMagick-2.6.0-ImageMagick-6.4.3-6-  
      Q8.zip) from the [RMagick project page](http://rubyforge.org/projects/rmagick/) on RubyForge.
   2. Unzip it into a temporary directory.
   3. Follow the instructions in the README.html.
         1. Run the ImageMagick installer (ImageMagick-6.4.3-6-Q8-windows-dll.exe) found in the temporary directory.
         2. Open a command prompt to the temporary directory.
         3. Use gem to install rmagick: gem install rmagick --local
         

##Develop##

###Retrieve Luvfoo from git hub###

Now that you have installed all of that fun stuff, it is time to pull down Luvfoo. To do this, open a command prompt, go to your root projects folder and use the git clone command:

git clone git://github.com/jbasdf/luvfoo.git

That will create a folder called luvfoo and copy the source code to it. If you want to copy the source to a folder other than Luvfoo, just specify the folder name at the end:

git clone git://github.com/jbasdf/luvfoo.git luvfoo2

Now that you have pulled the code down, you just need to install the gems (ruby libraries) that Luvfoo uses, set up some configuration files, and set up a database for Luvfoo to use.


###Configure Luvfoo###

Luvfoo utilizes a number of configuration files that you need to set up to get going:

config/global_config.yml
config/database.yml
config/initializers/mail.rb

Example files are included with luvfoo:

config/global_config.yml.example
config/database.yml.example
config/initializers/mail.rb.example

Copy or rename these files to get going.

If you are setting up a new Luvfoo instance, you will need to obtain various keys to put in the configuration files. For example, your website will need its own reCaptcha key. To get that, register on the [reCaptcha website](http://recaptcha.net/) and request a key.


###Install Luvfoo gem dependencies###

Luvfoo depends on the gems specified in config/environment.rb. Install them using the following [Rake](http://wiki.rubyonrails.org/rails/pages/WhatIsRakeAndWhatDoesItDo) command:

cd luvfoo
rake gems:install

Alternatively, you can install them one at a time using the gem command. For example:

gem install mocha

If you don't get all of the Gems installed, don't worry, when you try to run Luvfoo, it will complain about the missing Gems :-)

In case you are curious, rake is a software build tool.


###Set up databases for Luvfoo###

The database that Luvfoo uses is specified in the :development section /config/database.yml . You need to create the database:

mysqladmin -u <username> -p create <databasename>

For example:

mysqladmin -u root -p create luvfoo

Now use rake to load the Luvfoo schema into the database as following:

rake db:migrate

**Note**: Windows users need to load the win32console gem before using rake to load the Luvfoo schema. Use the following syntax to install the win32console-1.2.0-x86-mswin32-60 gem:

gem install win32console


###Run Luvfoo on your computer###

Before you run Luvfoo, you need to start up the solr server that Luvfoo uses to support searching:

**Linux & Mac**: rake solr:start

**Windows**: rake solr:start_win

**Note**: Windows users might run into the following error: **No connection could be made because the target machine actively refused it. - connect(2)**. To resolve this issue, follow the steps listed on [webonrails.com](http://webonrails.com/2007/09/13/acts_as_solr-starting-solr-server-on-windows/).

However, you might have to revert the **Errno::EBADF** to **Errno::ECONNREFUSED** in the modified vendor/plugins/acts_as_solr/lib/taks/solr.rake script for the solr server to start on windows.

Now you should be ready to run Luvfoo on your machine. For convenience in development, Ruby on Rails comes with two web servers, called [WEBrick](http://www.webrick.org/) and [Mongrel](http://mongrel.rubyforge.org/) that can be used to run Luvfoo. Use a ruby script to run Luvfoo using WEBrick:

ruby script/server webrick

Populate the database with test data:

rake luvfoo:db:populate

If all is not good, you will see error messages. If not, open Luvfoo in your favorite web browser: http://localhost:3000/

**Windows Specific Note**: As of 11/12/08, I am not able to install system_timer gem. My work around is to comment it out in environment.rb:

# config.gem 'SystemTimer', :lib => 'system_timer', :version => '1.0'

And in initializers/requires.rb:

# require 'system_timer' # lib/rss_methods.rb

I am not able to get the latest version of hpricot installed. To work around that, I change the required version in environment.rb:

config.gem 'hpricot', :version => '0.6'#.161'


###Merge the latest Luvfoo code from the master branch into another branch###

Now that you have the master branch running, you may want to pull down and develop on a different branch. At the command prompt where Luvfoo is running, press Ctrl + C to stop it.

Now pull down the branch from github:

git checkout --track -b <name for local branch> origin/<name of remote branch>

For example:

git checkout --track -b yfh origin/yfh

Use git to [merge](http://www.kernel.org/pub/software/scm/git/docs/git-merge.html) updates from the master branch into the branch you just checked out:

git merge master

Now try running the updated branch of Luvfoo to make sure all is well:

ruby script/server webrick 


###Run the Luvfoo tests###

Run rake using the following command to load the test schema:

rake db:test:prepare 

Install the following additional gems - these are required for testing:
    
* gem install thoughtbot-factory_girl 
* gem install zentest
* gem install thoughtbot-shoulda
* gem install redgreen
	
Rename the file **mail.rb** under ..\luvfoo\config\initializers to **mail.rb.example**, if not done already.  This is not needed for testing in the test environment.

To run all of the luvfoo tests:

rake test

To run just the unit, functional, or integration tests:

rake test:units
rake test:functionals
rake test:integration

To run a single test script:

ruby <test script ruby file>

For example:

ruby test/unit/user_test.rb

Each time you run a test the Rails environment is loaded and a clean database is set up. This takes significant time. To avoid this startup time, you can run the tests continuously using autotest:

autotest

When running autotest relevant tests are automatically re-run whenever you change a file.

For more information on Rails testing and autotest, and shoulda (the testing framework that Luvfoo uses) see [A Guide to Testing the Rails](http://manuals.rubyonrails.com/read/chapter/20), [Getting started with Autotest](http://ph7spot.com/articles/getting_started_with_autotest), and [Shoulda testing](http://www.thoughtbot.com/projects/shoulda).


###Set up an Aptana Studio project for working on Luvfoo###

In order to work on Luvfoo in Aptana Studio, you will want to create a project for it.

   1. Run Aptana
   2. Choose File, Project, New.
   3. Choose Rails Project from the Rails folder.
   4. Uncheck the "Use default location" checkbox.
   5. Specify the path to where you checked out Luvfoo with git (e.g. C:/Documents and Settings/Joel/My 
      Documents/projects/luvfoo).
   6. Specify a name for your project (e.g. yfh).
   7. Uncheck the "Generate Rails application skeleton", "Create a WEBrick server" and "Create a Mongrel server" 
      options.
   8. Click Finish. 

The project will be set up and its contents will be displayed in the Ruby Explorer on the left side panel.

Note: Aptana Studio comes with powerful recursive search functionality that can help you find things in Luvfoo. To use it, select the parent folder of the files you want to search in the Ruby Explorer, and then choose "File" from the "Search" menu.

**Note**: Aptana Studio is very configurable, but by default all files are considered to be ANSI encoded. This means that if you open a UTF8 encoded file or file containing special characters (such as Turkish) in it, the characters will not be displayed correctly. In Luvfoo, this applies especially to the .po translation files. To overcome this problem you can edit those files in a different editor (such as Notepad or poedit), or you can explicitly specify the encoding that Aptana Studio should consider the files to be. To change what encoding Aptana Studio should use for a file, right click on the file and choose Properties from the context sensitive menu. Then choose the "Other" Text file encoding option and select UTF-8, or another appropriate encoding scheme. Close and reopen the file if you already have it open.


###Update translation files###

If the branch that you are working on uses a language other than English, you may need to add or update translation strings. If the branch has been updated and added / changed strings to be translated, you need to make sure you have the latest strings to be translated. If the branch has not changed, but you just want to change the translation, you can just change the existing translation files.

**Make sure you have the latest strings to be translated**

Use rake to generate a new GetText translation template file (/po/luvfoo.pot):

rake updatepo

Next use GetText's msgmerge utility to merge the updated luvfoo.pot into the the language file for the translation used for your branch:

msgmerge <pot file> <po file that needs to be updated> -o <name for new po file>

For example:

msgmerge /po/luvfoo.pot /po/yfh-tr/luvfoo.po -o /po/yfh-tr/luvfoo.new.po

Back up the old po file and rename the location of the one used by luvfoo:

sudo mv /po/yfh-tr/luvfoo.po /po/yfh-tr/luvfoo.backup.po
sudo mv /po/yfh-tr/luvfoo.new.po /po/yfh-tr/luvfoo.po


###Update a translation file###

Open the po file (e.g. po/yfh-tr/luvfoo.po) in Notepad or a po utiity such as [poedit](http://www.poedit.net/). Add translations for any new messages that don't have one. In an editor, you can find these by searching for: msgstr "".

Now use rake to compile the po (text) file into a format that can be used by GetText (and luvfoo):

rake makemo

This compiles the translation file to:

locale/yfh-tr/luvfoo.mo

To test, your translation file, open or refresh the pages where the translation is used in your web browser. If you are running WEBrick in development mode, you should not need to restart it to see the updated translations.

Once you have modified a translation file, you need to copy it up to the server and put it in the correct place. You can do this either by using Capistrano to deploy a new copy of Luvfoo as described in the deploy section of this document, or by copying up just the translation file.

   1. Connect to the server with WinSCP.
   2. Copy the file to your home directory.
   3. SSH into the server.
   4. Copy the file to the deployment directory:
      sudo cp luvfoo.mo /var/www/ozmozr/current/locale/yfh-tr/
   5. Change to the luvfoo current directory:
      cd /var/www/ozmozr/current/
   6. Restart luvfoo:
      sudo mongrel_rails cluster::restart


###Commit changes to a Luvfoo branch###

In order to deploy updates, first commit your changes to your local repository, and then push them up to github. The gui provided with git can be helpful for reviewing and committing changes:

git gui

Select the changed or added files and click Ctrl + T to stage them for committing. Then type a message describing the commit, and click the Commit button. It is a good idea to create commits that group related changes.


###Push Luvfoo changes to github###

After you commit changes to your local repository, you can push those changes up to github so they can be pulled down to your production server. If you are still in git gui, do this by clicking the Push button. 


##Deploy##

###Generate a private / public key pair and copy your public key to the remote server###

Capistrano uses ssh to connect to a linux server to deploy Luvfoo. In order to for this secure connection to occur, you need to set create a private / public key pair on your computer and copy the public key up to the remote server.

   1. Go to a command prompt. 


###Deploy Luvfoo to the remote server###

Once Capistrano is set up, deploying Luvfoo is as simple as going to the root of Luvfoo at the MINGW32 command prompt and running:

cap deploy

Watch the messages it spits out and cross your fingers. Depending on how you have things configured, it may prompt you for the sudo password so it can restart mongrel.

If an error occurs, Capistrano should automatically roll back the deployment and leave you at the state it was in before the deployment was attempted. If you need to manually roll back a deployment:

cap deploy:rollback

When you run cap deploy, it executes the Capfile script located in the current directory. For Rails projects, this file typically just executes config/deploy.rb script.

To see all tasks available via Capistrano:

cap -Tv

Capistrano uses the following directory structure on the server to deploy applications:

<containing folder>
<containing folder>/shared
<containing folder>/current (symbolic link)
<containing folder>/current/<project files>
<containing folder>/releases
<containing folder>/releases/<timestamp>/<project files>

For example:

/var/www/ozmozr/
/var/www/ozmozr/shared/
/var/www/ozmozr/current/
/var/www/ozmozr/current/app/ (and so on)
/var/www/ozmozr/releases/200805032003
/var/www/ozmozr/releases/200805032003/app (and so on)

<containing folder>/shared
This is where shared files that aren't replaced each time you deploy. For example config/global_config.yml and config/initializers/mail.rb As part of deploying an application, Capistrano sets up symbolic links from these files to the locations where they need to appear underneath the current folder where the application is run from.

<containing folder>/current
This is a symbolic link to a specific release folder (e.g. /var/www/ozmozr/releases/200805032003)

For more information on Capistrano see the [Capistrano project website](http://www.capify.org/).


###Diagnose and fix problems on the server###

If Luvfoo doesn't start up, you can tail the production.log to see if it provides any clues about what is happening.

tail -F logs/production.log

To verify that Luvfoo is running you can check to see that the Rails server is up and running. If it is mongrel:

sudo ps -ef|grep mongrel

You can also look at the processes:

top

Then press Ctrl+M to sort processes by how much memory they are using.


###Restart mongrel###

Sometimes you may need to restart mongrel. Go to the current folder and run:

sudo mongrel_rails cluster::restart

To just stop or start mongrel:

sudo mongrel_rails cluster::stop
sudo mongrel_rails cluster::start

Of course if mongrel gets fiesty and won't shut down, there is always:

sudo kill -9 <process id>

To find out the process id for mongrel, use:

sudo ps -ef|grep mongrel