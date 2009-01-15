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
      
      user = User.find(1)
      
#      user.update_property_bag
      user.salesforce_sync

      sf_user = Contact.find(:first, :conditions => ['email = ?', user.email])
      puts '***************************'
      puts 'phone in SF:' + sf_user.phone
      puts 'phone in system:' + user.property_value('phone')
      puts '***************************'
      
 #     user.update_property_bag
      user.salesforce_sync
                  
      sf_user = Contact.find(:first, :conditions => ['email = ?', user.email])
      puts '***************************'
      puts 'phone in SF:' + sf_user.phone
      puts 'phone in system:' + user.property_value('phone')
      puts '***************************'
      
    end
  end
end
