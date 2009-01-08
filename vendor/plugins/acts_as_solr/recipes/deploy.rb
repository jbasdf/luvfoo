namespace :solr do
  
  task :start, :roles => :app do
    run "cd #{latest_release} && #{rake} solr:start RAILS_ENV=production 2>/dev/null"
  end
  
  task :stop, :roles => :app do
    run "cd #{latest_release} && #{rake} solr:stop RAILS_ENV=production 2>/dev/null"
  end
  
  task :restart, :roles => :app do
    solr.stop
    solr.start
  end
  
end