namespace :luvfoo do
  namespace :salesforce do
    desc "Send data for all users to salesforce"
    task :sync => :environment do
      
      users = User.find(:all)
      
      users.each do |user|
        user.salesforce_sync
        puts "Finished syncing #{user.login}"
      end
      
    end
  end
end


namespace :luvfoo do
  namespace :salesforce do
    desc "Send a limited amount of data to salesforce for testing"
    task :test => :environment do
      
      # users = User.find(:all, :limit => 10)
      #       
      #       users.each do |user|
      #         user.salesforce_sync
      #         puts "Finished syncing #{user.login}"
      #       end
      
      user = User.find(1)
      user.salesforce_sync
      
    end
  end
end
