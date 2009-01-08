namespace :db do
  ENV["DB_MIGRATION"] = "true"
end

namespace :luvfoo do
  namespace :db do

    ENV["DB_MIGRATION"] = "true"
    desc "drops and rebuilds all databases"
    task :dodb do

      puts 'resetting databases'

      puts 'droping databases'
      system "rake db:drop:all"

      puts 'creating databases'
      system "rake db:create:all"

      puts 'migrating'
      system "rake db:migrate"

      puts 'setting up test db'
      system "rake db:test:prepare"

      puts 'annotating models'
      system "rake annotate_models"

    end

    desc "updates all databases and annotates models"
    task :updb do

      puts 'migrating'
      system "rake db:migrate"

      puts 'setting up test db'
      system "rake db:create RAILS_ENV=test"
      system "rake db:test:prepare"

      puts 'annotating models'
      system "rake annotate_models"

    end

    # For this task to work you must comment out acts_as_solr in user.rb.
    # acts_as_solr foobars stuff
    desc "resets all databases and loads in database script from parent directory."
    task :redb do

      puts 'resetting databases'

      puts 'droping databases'
      system "rake db:drop:all"

      puts 'creating databases'
      system "rake db:create:all"

      system "mysql -u root luvfoo < ../lovdbyless.sql"
      system "mysql -u root luvfoo_production < ../lovdbyless.sql"

      puts 'migrating'
      system "rake db:migrate"

      puts 'setting up test db'
      system "rake db:test:prepare"

      puts 'annotating models'
      system "rake annotate_models"

    end

  end
end