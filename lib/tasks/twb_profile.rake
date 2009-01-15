namespace :luvfoo do
  namespace :db do
    desc "Build profile caches from property bags"
    task :update_profile_cache => :environment do
      require 'net/http'
      User.find(:all, :conditions => 'public_profile IS NULL').each do |user|
        puts 'Generating profile cache for: ' + user.login
        user.public_profile = Net::HTTP.get_response(URI.parse('http://' + GlobalConfig.application_base_url + '/profiles/' + user.id.to_s + '/cache')).body
        user.save(false)
      end
    end
  end
  
  namespace :db do
    desc "Transfer data from user model to property bags"
    task :migrate_twb_profile => :environment do

      sql = ActiveRecord::Base.connection()
      sql.execute("DELETE FROM bag_property_values")

      bag_property_ids = {}
      BagProperty.find(:all).each do |p|
        bag_property_ids[p.name] = p.id
      end

      professional_role_id = bag_property_ids["professional_role"]
      professional_role_enums = BagPropertyEnum.find(:all, :conditions => {:bag_property_id => professional_role_id})
      professional_role_enum_ids = {}
      ProfessionalRole.find(:all).each do |professional_role|
        pr = professional_role_enums.find{|i| i.name == professional_role.name}
        professional_role_enum_ids[professional_role.id] = pr.id if pr != nil
      end

      volunteer_interests_id = bag_property_ids["volunteer_interests"]
      interest_enums = BagPropertyEnum.find(:all, :conditions => {:bag_property_id => volunteer_interests_id})
      interest_enum_ids = {}
      Interest.find(:all).each do |interest|
        interest_enum_ids[interest.id] = interest_enums.find{|i| i.name == interest.name}.id
      end

      language_id = bag_property_ids["language"]
      language_enums = BagPropertyEnum.find(:all, :conditions => {:bag_property_id => language_id})
      language_enum_ids = {}
      Language.find(:all).each do |language|
        l = language_enums.find{|i| i.name == language.english_name}
        language_enum_ids[language.id] = l.id if l != nil
      end
      
      other_languages_id = bag_property_ids["other_languages"]
      other_languages_enums = BagPropertyEnum.find(:all, :conditions => {:bag_property_id => other_languages_id})
      other_languages_enum_ids = {}
      Language.find(:all).each do |language|
        l = other_languages_enums.find{|i| i.name == language.english_name}
        other_languages_enum_ids[language.id] = l.id if l != nil
      end
      
      state_names = {}
      State.find(:all).each do |state|
        state_names[state.id] = state.name
      end
      
      country_id = bag_property_ids["country"]
      country_enums = BagPropertyEnum.find(:all, :conditions => {:bag_property_id => country_id})
      country_enum_ids = {}
      Country.find(:all).each do |country|
        l = country_enums.find{|i| i.name == country.name}
        country_enum_ids[country.id] = l.id if l != nil
      end

      experience_id = bag_property_ids["teaching_experience"]
      experience_enums = BagPropertyEnum.find(:all, :conditions => {:bag_property_id => experience_id})
      experience_enum_ids = {}
      GradeLevelExperience.find(:all).each do |experience|
        l = experience_enums.find{|i| i.name == experience.name}
        experience_enum_ids[experience.id] = l.id if l != nil
      end

      User.find(:all).each do |user|
        
        puts "migrating: #{user.login}"

        if user.professional_role_id != nil
          bag_property_id = bag_property_ids["professional_role"]
          BagPropertyValue.create(:data_type => BagProperty::DATA_TYPE_ENUM, :user_id => user.id, 
            :bag_property_id => bag_property_id,  :bag_property_enum_id => professional_role_enum_ids[user.professional_role_id], 
            :visibility => BagProperty::VISIBILITY_EVERYONE)
        end
      
        # none of the existing accounts have an professional_role_other value
        #bag_property_id = bag_property_ids["professional_role_other")
      
        if user.why_joined != nil && !user.why_joined.empty?
          bag_property_id = bag_property_ids["why_joined"]
          BagPropertyValue.create(:data_type => BagProperty::DATA_TYPE_TEXT, :user_id => user.id, 
            :bag_property_id => bag_property_id, :visibility => BagProperty::VISIBILITY_EVERYONE, 
            :tvalue => user.why_joined)
        end
      
        if user.about_me != nil && !user.about_me.empty?
          bag_property_id = bag_property_ids["about_me"]
          BagPropertyValue.create(:data_type => BagProperty::DATA_TYPE_TEXT, :user_id => user.id, 
            :bag_property_id => bag_property_id, :visibility => BagProperty::VISIBILITY_USERS, 
            :tvalue => user.about_me)
        end
        
        bag_property_id = bag_property_ids["volunteer_interests"]
        user.interests.each do |interest|
          BagPropertyValue.create(:data_type => BagProperty::DATA_TYPE_ENUM, :user_id => user.id, 
            :bag_property_id => bag_property_id, :bag_property_enum_id => interest_enum_ids[interest.id], 
            :visibility => BagProperty::VISIBILITY_USERS)  
        end
      
        if user.language_id != nil
          bag_property_id = bag_property_ids["language"]
          BagPropertyValue.create(:data_type => BagProperty::DATA_TYPE_ENUM, :user_id => user.id, 
            :bag_property_id => bag_property_id, :bag_property_enum_id => language_enum_ids[user.language_id], 
            :visibility => BagProperty::VISIBILITY_EVERYONE)  
        end
      
        bag_property_id = bag_property_ids["other_languages"]
        user.languages.each do |language|
          BagPropertyValue.create(:data_type => BagProperty::DATA_TYPE_ENUM, :user_id => user.id, 
            :bag_property_id => bag_property_id, :bag_property_enum_id => other_languages_enum_ids[language.id], 
            :visibility => BagProperty::VISIBILITY_EVERYONE)
        end
      
        # none of the existing accounts have an address account
        #bag_property_id = bag_property_ids["address")
      
        if user.city != nil && !user.city.empty?
          bag_property_id = bag_property_ids["city"]
          BagPropertyValue.create(:data_type => BagProperty::DATA_TYPE_STRING, :user_id => user.id, 
            :bag_property_id => bag_property_id, :visibility => BagProperty::VISIBILITY_USERS, 
            :svalue => user.city)
        end
      
        if user.state_id != nil && user.state_id != 2 
          bag_property_id = bag_property_ids["state"]
          BagPropertyValue.create(:data_type => BagProperty::DATA_TYPE_STRING, :user_id => user.id, 
            :bag_property_id => bag_property_id, :visibility => BagProperty::VISIBILITY_USERS, 
            :svalue => state_names[user.state_id])
        end
      
        if user.country_id != nil && user.country_id != 6
          bag_property_id = bag_property_ids["country"]
          BagPropertyValue.create(:data_type => BagProperty::DATA_TYPE_ENUM, :user_id => user.id, 
            :bag_property_id => bag_property_id, :bag_property_enum_id => country_enum_ids[user.country_id], 
            :visibility => BagProperty::VISIBILITY_USERS)
        end
      
        if user.zip != nil && !user.zip.empty?
          bag_property_id = bag_property_ids["zip"]
          BagPropertyValue.create(:data_type => BagProperty::DATA_TYPE_STRING, :user_id => user.id, 
            :bag_property_id => bag_property_id, :visibility => BagProperty::VISIBILITY_ADMIN, 
            :svalue => user.zip)
        end
      
        if user.phone != nil && !user.phone.empty?
          bag_property_id = bag_property_ids["phone"]
          BagPropertyValue.create(:data_type => BagProperty::DATA_TYPE_STRING, :user_id => user.id, 
            :bag_property_id => bag_property_id, :visibility => BagProperty::VISIBILITY_ADMIN, 
            :svalue => user.phone)  
        end
        
        if user.organization != nil && !user.organization.empty?
          bag_property_id = bag_property_ids["organization"]
          BagPropertyValue.create(:data_type => BagProperty::DATA_TYPE_STRING, :user_id => user.id, 
            :bag_property_id => bag_property_id, :visibility => BagProperty::VISIBILITY_USERS, 
            :svalue => user.organization)
        end
      
        bag_property_id = bag_property_ids["teaching_experience"]
        user.grade_level_experiences.each do |experience|
          BagPropertyValue.create(:data_type => BagProperty::DATA_TYPE_ENUM, :user_id => user.id, 
            :bag_property_id => bag_property_id, :bag_property_enum_id => experience_enum_ids[experience.id], 
            :visibility => BagProperty::VISIBILITY_USERS)
        end
      
        if user.skills != nil && !user.skills.empty?
          bag_property_id = bag_property_ids["skills"]
          BagPropertyValue.create(:data_type => BagProperty::DATA_TYPE_TEXT, :user_id => user.id, 
            :bag_property_id => bag_property_id, :visibility => BagProperty::VISIBILITY_USERS, 
            :tvalue => user.skills)
        end
      
        if user.occupation != nil && !user.occupation.empty?
          bag_property_id = bag_property_ids["occupation"]
          BagPropertyValue.create(:data_type => BagProperty::DATA_TYPE_TEXT, :user_id => user.id, 
            :bag_property_id => bag_property_id, :visibility => BagProperty::VISIBILITY_USERS, 
            :tvalue => user.occupation)  
        end
        
        if user.website != nil && !user.website.empty?
          bag_property_id = bag_property_ids["website"]
          BagPropertyValue.create(:data_type => BagProperty::DATA_TYPE_STRING, :user_id => user.id, 
            :bag_property_id => bag_property_id, :visibility => BagProperty::VISIBILITY_USERS, 
            :svalue => user.website)  
        end
        
        if user.blog != nil && !user.blog.empty?
          bag_property_id = bag_property_ids["blog"]
          BagPropertyValue.create(:data_type => BagProperty::DATA_TYPE_STRING, :user_id => user.id, 
            :bag_property_id => bag_property_id, :visibility => BagProperty::VISIBILITY_USERS, 
            :svalue => user.blog)  
        end      
        
        if user.youtube_username != nil && !user.youtube_username.empty?
          bag_property_id = bag_property_ids["youtube_username"]
          BagPropertyValue.create(:data_type => BagProperty::DATA_TYPE_STRING, :user_id => user.id, 
            :bag_property_id => bag_property_id, :visibility => BagProperty::VISIBILITY_USERS, 
            :svalue => user.youtube_username)
        end
      
        if user.flickr_username != nil && !user.flickr_username.empty?
        bag_property_id = bag_property_ids["flickr_username"]
        BagPropertyValue.create(:data_type => BagProperty::DATA_TYPE_STRING, :user_id => user.id, 
          :bag_property_id => bag_property_id, :visibility => BagProperty::VISIBILITY_FRIENDS, 
          :svalue => user.flickr_username)  
        end
        
        if user.aim_name != nil && !user.aim_name.empty?
          bag_property_id = bag_property_ids["aim_name"]
          BagPropertyValue.create(:data_type => BagProperty::DATA_TYPE_STRING, :user_id => user.id, 
          :bag_property_id => bag_property_id, :visibility => BagProperty::VISIBILITY_FRIENDS, 
            :svalue => user.aim_name)
        end
      
        if user.msn != nil && !user.msn.empty?
          bag_property_id = bag_property_ids["msn"]
          BagPropertyValue.create(:data_type => BagProperty::DATA_TYPE_STRING, :user_id => user.id, 
          :bag_property_id => bag_property_id, :visibility => BagProperty::VISIBILITY_FRIENDS, 
            :svalue => user.msn)
        end
      
        if user.skype != nil && !user.skype.empty?
          bag_property_id = bag_property_ids["skype"]
          BagPropertyValue.create(:data_type => BagProperty::DATA_TYPE_STRING, :user_id => user.id, 
          :bag_property_id => bag_property_id, :visibility => BagProperty::VISIBILITY_FRIENDS, 
            :svalue => user.skype)  
        end
      
        if user.yahoo != nil && !user.yahoo.empty?
          bag_property_id = bag_property_ids["yahoo"]
          BagPropertyValue.create(:data_type => BagProperty::DATA_TYPE_STRING, :user_id => user.id, 
          :bag_property_id => bag_property_id, :visibility => BagProperty::VISIBILITY_FRIENDS, 
            :svalue => user.yahoo)  
        end
      
        if user.gtalk_name != nil && !user.gtalk_name.empty?
          bag_property_id = bag_property_ids["gtalk_name"]
          BagPropertyValue.create(:data_type => BagProperty::DATA_TYPE_STRING, :user_id => user.id, 
          :bag_property_id => bag_property_id, :visibility => BagProperty::VISIBILITY_FRIENDS, 
            :svalue => user.gtalk_name)  
        end
      
        if user.ichat_name != nil && !user.ichat_name.empty?
          bag_property_id = bag_property_ids["ichat_name"]
          BagPropertyValue.create(:data_type => BagProperty::DATA_TYPE_STRING, :user_id => user.id, 
          :bag_property_id => bag_property_id, :visibility => BagProperty::VISIBILITY_FRIENDS, 
            :svalue => user.ichat_name)
        end
          
        BagPropertyValue.create(:bag_property_id => bag_property_ids['view_blog'], :visibility => BagProperty::VISIBILITY_USERS)
        BagPropertyValue.create(:bag_property_id => bag_property_ids['view_photos'], :visibility => BagProperty::VISIBILITY_USERS)
        BagPropertyValue.create(:bag_property_id => bag_property_ids['view_groups'], :visibility => BagProperty::VISIBILITY_USERS)
        BagPropertyValue.create(:bag_property_id => bag_property_ids['view_colleagues'], :visibility => BagProperty::VISIBILITY_USERS)
        BagPropertyValue.create(:bag_property_id => bag_property_ids['view_activities'], :visibility => BagProperty::VISIBILITY_USERS)
        BagPropertyValue.create(:bag_property_id => bag_property_ids['direct_message'], :visibility => BagProperty::VISIBILITY_USERS)
        BagPropertyValue.create(:bag_property_id => bag_property_ids['share_doc'], :visibility => BagProperty::VISIBILITY_USERS)

      end
    end
  end
 
  namespace :db do
    desc "Add twb profile fields to the database"
    task :load_twb_profile => :environment do

      sql = ActiveRecord::Base.connection()
      sql.execute("DELETE FROM bag_properties")
      sql.execute("DELETE FROM bag_property_enums")
      
      BagProperty.create(
        :name => 'professional_role', 
        :label => 'Professional Role', 
        :data_type => BagProperty::DATA_TYPE_ENUM,
        :display_type => BagProperty::DISPLAY_TYPE_DROP_DOWN_LIST, 
        :required => true, 
        :default_visibility => BagProperty::VISIBILITY_EVERYONE,
        :registration_page => 1,
        :can_change_visibility => false,
        :sort => 10 
      )
      professional_role_id = BagProperty.find_by_name("professional_role").id
      [
        [1, "Certified/Licensed Educator", 1],
        [2, "Noncertified Educator", 2],
        [6, "Retired Eucator", 20],
        [4, "Other Educator", 20],
        [3, "Post Secondary Student", 30],
        [5, "Other", 9999]
      ].each {|pr| BagPropertyEnum.create(:bag_property_id => professional_role_id, :value => pr[0], :name => pr[1], :sort => pr[2]) }

      BagProperty.create(
        :name => 'professional_role_other', 
        :label => 'Other Professional Role', 
        :data_type => BagProperty::DATA_TYPE_STRING,
        :display_type => BagProperty::DISPLAY_TYPE_TEXT, 
        :default_visibility => BagProperty::VISIBILITY_EVERYONE, 
        :registration_page => 1,
        :required => true,
        :can_change_visibility => false,
        :sort => 20 
      )

      BagProperty.create(:name => 'why_joined', :label => 'Why joined TWB', :default_visibility => BagProperty::VISIBILITY_EVERYONE, :data_type => BagProperty::DATA_TYPE_TEXT, :display_type => BagProperty::DISPLAY_TYPE_TEXT_AREA, :sort => 30, :registration_page => 1, :required => true, :can_change_visibility => false, :maxlength => 250) 
      BagProperty.create(:name => 'about_me', :label => 'About Me', :data_type => BagProperty::DATA_TYPE_TEXT, :display_type => BagProperty::DISPLAY_TYPE_TEXT_AREA, :sort => 35, :default_visibility => BagProperty::VISIBILITY_EVERYONE) 

      BagProperty.create(
        :name => 'volunteer_interests', 
        :label => 'Volunteer Interests', 
        :data_type => BagProperty::DATA_TYPE_ENUM,
        :display_type => BagProperty::DISPLAY_TYPE_CHECK_BOX_LIST, 
        :default_visibility => BagProperty::VISIBILITY_USERS,
        :height => 200,
        :sort => 40 
      )
      volunteer_interests_id = BagProperty.find_by_name("volunteer_interests").id
      [
        ['Internships', 1],
        ['Content Creators', 2],
        ['Curriculum Development', 3],
        ['Database/Programming', 4],
        ['Digital Media', 5],
        ['Evaluation Measurements', 6],
        ['Fundraising', 7],
        ['Grant Research/Writing', 8],
        ['Marketing', 10],
        ['Membership Outreach', 20],
        ['Mentor Teaching', 30],
        ['Workshop Facilitation', 40],
        ['Researchers', 50],
        ['Translation', 60],
        ['TWB On Campus',70],
        ['Technology Support',80],
        ['Website Expertise',90],
        ['Certificate of Teaching Mastery Mentor',100],
        ['Peer Journal Review',110],
        ['Other', 120],
        ['Only interested in receiving information via email',130]
     ].each {|vi| BagPropertyEnum.create(:bag_property_id => volunteer_interests_id, :value => vi[0], :name => vi[0], :sort => vi[1]) }
      
      
#      BagProperty.create(:name => 'location', :label => 'Location', :sort => 5)
      
      BagProperty.create(
        :name => 'language', 
        :label => 'First Language', 
        :data_type => BagProperty::DATA_TYPE_ENUM,
        :display_type => BagProperty::DISPLAY_TYPE_DROP_DOWN_LIST,
        :can_change_visibility => false,
        :registration_page => 1,
        :required => true,
        :sort => 50 
      )
      language_id = BagProperty.find_by_name("language").id
      [
        ['English', 'English', true],
        ['Afar', 'Afar', false],
        ['Abkhazian', 'Abkhazian', false],
        ['Afrikaans', 'Afrikaans', false],
        ['Amharic', 'Amharic', false],
        ['Arabic', 'Arabic', false],
        ['Assamese', 'Assamese', false],
        ['Aymara', 'Aymara', false],
        ['Azerbaijani', 'Azerbaijani', false],
        ['Bashkir', 'Bashkir', false],
        ['Belarussian', 'Belarussian', false],
        ['Bulgarian', 'Bulgarian', false],
        ['Bihari', 'Bihari', false],
        ['Bislama', 'Bislama', false],
        ['Bengali', 'Bengali', false],
        ['Tibetan', 'Tibetan', false],
        ['Bosanski', 'Bosnian', false],
        ['Brezhoneg', 'Breton', false],
        ['Catalan', 'Catalan', false],
        ['Corsu', 'Corsican', false],
        ['Czech', 'Czech', false],
        ['Cymraeg', 'Welsh', false],
        ['Dansk', 'Danish', false],
        ['Deutsch', 'German', false],
        ['Bhutani', 'Indian Bhutani', false],
        ['Greek', 'Greek', false],
        ['Esperanto', 'Esperanto', false],
        ['Spanish', 'Spanish', false],
        ['Eesti', 'Estonian', false],
        ['Euskara', 'Basque', false],
        ['Persian', 'Persian', false],
        ['Suomi', 'Finnish', false],
        ['Fiji', 'Fiji', false],
        ['F√∏royska', 'Faroese', false],
        ['Fran√ßais', 'French', false],
        ['Frysk', 'Frisian', false],
        ['Gaeilge', 'Irish Gaelic', false],
        ['G√†idhlig', 'Scottish Gaelic', false],
        ['Galego', 'Galician', false],
        ['Guarani', 'Guarani', false],
        ['‡™ó‡´Å‡™ú‡™∞‡™æ‡™§‡´Ä', 'Gujarati', false],
        ['Gaelg', 'Manx Gaelic', false],
        ['ŸáŸéŸàŸèÿ≥', 'Hausa', false],
        ['◊¢◊ë◊®◊ô◊™', 'Hebrew', false],
        ['‡§π‡§ø‡§Ç‡§¶‡•Ä', 'Hindi', false],
        ['Hrvatski', 'Croatian', false],
        ['Magyar', 'Hungarian', false],
        ['’Ä’°’µ’•÷Ä’ß’∂', 'Armenian', false],
        ['Interlingua', 'Interlingua', false],
        ['Bahasa Indonesia', 'Indonesian', false],
        ['Interlingue', 'Interlingue', false],
        ['Inupiak', 'Inupiak', false],
        ['√çslenska', 'Icelandic', false],
        ['Italiano', 'Italian', false],
        ['·êÉ·ìÑ·íÉ·ëé·ëê·ë¶', 'Inuktitut', false],
        ['Êó•Êú¨Ë™û', 'Japanese', false],
        ['Javanese', 'Javanese', false],
        ['·É•·Éê·É†·Éó·É£·Éö·Éò', 'Georgian', false],
        ['ÔªóÔ∫éÔ∫ØÔ∫çÔªóÔ∫∏Ô∫é', 'Kazakh', false],
        ['Greenlandic', 'Greenlandic', false],
        ['·ûÅ·üí·ûò·üÇ·ûö', 'Cambodian/Khmer', false],
        ['‡≤ï‡≤®‡≥ç‡≤®‡≤°', 'Kannada', false],
        ['ÌïúÍµ≠Ïñ¥', 'Korean', false],
        ['‡§ï‡§æ‡§Ω‡§∂‡•Å‡§∞', 'Kashmiri', false],
        ['Kurd√≠', 'Kurdish', false],
        ['Kernewek', 'Cornish', false],
        ['–ö—ã—Ä–≥—ã–∑', 'Kirghiz', false],
        ['Latin', 'Latin', false],
        ['L√´tzebuergesch', 'Luxemburgish', false],
        ['Limburgs', 'Limburgish', false],
        ['Lingala', 'Lingala', false],
        ['‡∫û‡∫≤‡∫™‡∫≤‡∫•‡∫≤‡∫ß', 'Laotian', false],
        ['Lietuviskai', 'Lithuanian', false],
        ['Latvie≈°u', 'Latvian', false],
        ['Malagasy', 'Madagascarian', false],
        ['Maldives', 'Maldives', false],
        ['Maori', 'Maori', false],
        ['–ú–∞–∫–µ–¥–æ–Ω—Å–∫–∏', 'Macedonian', false],
        ['‡¥Æ‡¥≤‡¥Ø‡¥æ‡¥≥‡¥Ç', 'Malayalam', false],
        ['–ú–æ–Ω–≥–æ–ª', 'Mongolian', false],
        ['Moldavian', 'Moldavian', false],
        ['‡§Æ‡§∞‡§æ‡§†‡•Ä', 'Marathi', false],
        ['Bahasa Melayu', 'Malay', false],
        ['Malti', 'Maltese', false],
        ['Burmese', 'Burmese', false],
        ['Nauru', 'Nauruan', false],
        ['‡§®‡•á‡§™‡§æ‡§≤‡•Ä', 'Nepali', false],
        ['Nederlands', 'Dutch', false],
        ['Norsk', 'Norwegian', false],
        ['Nynorsk', 'Nynorsk', false],
        ['Occitan', 'Occitan', false],
        ['Oromo', 'Oromo', false],
        ['‡¨ì‡≠ú‡¨ø‡¨Ü', 'Oriya', false],
        ['Palestine', 'Palestine', false],
        ['‡®™‡©∞‡®ú‡®æ‡®¨‡©Ä', 'Punjabi', false],
        ['Polski', 'Polish', false],
        ['Ÿæ⁄öÿ™Ÿà', 'Pashto', false],
        ['Portugu√™s', 'Portuguese', false],
        ['Quechua', 'Quechua', false],
        ['Rhaeto-Romance', 'Rhaeto-Romance', false],
        ['Kirundi', 'Kirundi', false],
        ['Rom√¢nƒÉ', 'Romanian', false],
        ['–†—É—Å—Å–∫–∏–π', 'Russian', false],
        ['Kiyarwanda', 'Kiyarwanda', false],
        ['‡§∏‡§Ç‡§∏‡•ç‡§ï‡•É‡§§', 'Sanskrit', false],
        ['Sindhi', 'Sindhi', false],
#        ['Northern S√°mi', 'Northern S√°mi', false],
        ['Sangho', 'Sangho', false],
        ['Serbo-Croatian', 'Serbo-Croatian', false],
        ['Singhalese', 'Singhalese', false],
        ['Slovenƒçina', 'Slovak', false],
        ['Sloven≈°ƒçina', 'Slovenian', false],
        ['Samoan', 'Samoan', false],
        ['Shona', 'Shona', false],
        ['Somali', 'Somali', false],
        ['Shqip', 'Albanian', false],
        ['—Å—Ä–ø—Å–∫–∏', 'Serbian', false],
        ['Siswati', 'Siswati', false],
        ['Sesotho', 'Sesotho', false],
        ['Sudanese', 'Sudanese', false],
        ['Svenska', 'Swedish', false],
        ['Swahili', 'Swahili', false],
        ['‡Æ§‡ÆÆ‡Æø‡Æ¥', 'Tamil', false],
        ['‡∞§‡±Ü‡∞≤‡±Å‡∞ó‡±Å', 'Telugu', false],
        ['–¢–æ“∑–∏–∫–∏', 'Tadjik', false],
        ['‡πÑ‡∏ó‡∏¢', 'Thai', false],
        ['·âµ·åç·à≠·äõ', 'Tigrinya', false],
        ['—Ç“Ø—Ä–∫m–µ–Ω—á–µ', 'Turkmen', false],
        ['Tagalog', 'Tagalog', false],
        ['Setswana', 'Setswana', false],
        ['Tonga', 'Tonga', false],
        ['T√ºrk√ße', 'Turkish', false],
        ['Tsonga', 'Tsonga', false],
        ['—Ç–∞—Ç–∞—Ä—á–∞', 'Tatar', false],
        ['Twi', 'Twi', false],
        ['Uigur', 'Uigur', false],
        ['–£–∫—Ä–∞—ó–Ω—Å—å–∫–∞', 'Ukrainian', false],
        ['ÿßÿ±ÿØŸà', 'Urdu', false],
        ['–é–∑–±–µ–∫—á–∞', 'Uzbek', false],
        ['Ti·∫øng Vi·ªát', 'Vietnamese', false],
#        ['Volap√ºk', 'Volap√ºk', false],
        ['Walon', 'Walloon', false],
        ['Wolof', 'Wolof', false],
        ['isiXhosa', 'Xhosa', false],
        ['◊≤÷¥◊ì◊ô◊©', 'Yiddish', false],
        ['Yor√πb√°', 'Yorouba', false],
        ['Zhuang', 'Zhuang', false],
        ['zh-HK', 'Chinese - Traditional', false],
        ['zh-CN', 'Chinese - Simplified', false],
        ['isiZulu', 'Zulu', false]
      ].each {|l| BagPropertyEnum.create(:bag_property_id => language_id, :value => l[1], :name => l[1]) }

      BagProperty.create(
        :name => 'other_languages', 
        :label => 'Other Languages', 
        :data_type => BagProperty::DATA_TYPE_ENUM,
        :display_type => BagProperty::DISPLAY_TYPE_CHECK_BOX_LIST, 
        :default_visibility => BagProperty::VISIBILITY_USERS,
        :can_change_visibility => false,
        :height => 200,
        :sort => 60 
      )
      other_languages_id = BagProperty.find_by_name("other_languages").id
      [
        ['English', 'English', true],
        ['Afar', 'Afar', false],
        ['Abkhazian', 'Abkhazian', false],
        ['Afrikaans', 'Afrikaans', false],
        ['Amharic', 'Amharic', false],
        ['Arabic', 'Arabic', false],
        ['Assamese', 'Assamese', false],
        ['Aymara', 'Aymara', false],
        ['Azerbaijani', 'Azerbaijani', false],
        ['Bashkir', 'Bashkir', false],
        ['Belarussian', 'Belarussian', false],
        ['Bulgarian', 'Bulgarian', false],
        ['Bihari', 'Bihari', false],
        ['Bislama', 'Bislama', false],
        ['Bengali', 'Bengali', false],
        ['Tibetan', 'Tibetan', false],
        ['Bosanski', 'Bosnian', false],
        ['Brezhoneg', 'Breton', false],
        ['Catalan', 'Catalan', false],
        ['Corsu', 'Corsican', false],
        ['Czech', 'Czech', false],
        ['Cymraeg', 'Welsh', false],
        ['Dansk', 'Danish', false],
        ['Deutsch', 'German', false],
        ['Bhutani', 'Indian Bhutani', false],
        ['Greek', 'Greek', false],
        ['Esperanto', 'Esperanto', false],
        ['Spanish', 'Spanish', false],
        ['Eesti', 'Estonian', false],
        ['Euskara', 'Basque', false],
        ['Persian', 'Persian', false],
        ['Suomi', 'Finnish', false],
        ['Fiji', 'Fiji', false],
        ['F√∏royska', 'Faroese', false],
        ['Fran√ßais', 'French', false],
        ['Frysk', 'Frisian', false],
        ['Gaeilge', 'Irish Gaelic', false],
        ['G√†idhlig', 'Scottish Gaelic', false],
        ['Galego', 'Galician', false],
        ['Guarani', 'Guarani', false],
        ['‡™ó‡´Å‡™ú‡™∞‡™æ‡™§‡´Ä', 'Gujarati', false],
        ['Gaelg', 'Manx Gaelic', false],
        ['ŸáŸéŸàŸèÿ≥', 'Hausa', false],
        ['◊¢◊ë◊®◊ô◊™', 'Hebrew', false],
        ['‡§π‡§ø‡§Ç‡§¶‡•Ä', 'Hindi', false],
        ['Hrvatski', 'Croatian', false],
        ['Magyar', 'Hungarian', false],
        ['’Ä’°’µ’•÷Ä’ß’∂', 'Armenian', false],
        ['Interlingua', 'Interlingua', false],
        ['Bahasa Indonesia', 'Indonesian', false],
        ['Interlingue', 'Interlingue', false],
        ['Inupiak', 'Inupiak', false],
        ['√çslenska', 'Icelandic', false],
        ['Italiano', 'Italian', false],
        ['·êÉ·ìÑ·íÉ·ëé·ëê·ë¶', 'Inuktitut', false],
        ['Êó•Êú¨Ë™û', 'Japanese', false],
        ['Javanese', 'Javanese', false],
        ['·É•·Éê·É†·Éó·É£·Éö·Éò', 'Georgian', false],
        ['ÔªóÔ∫éÔ∫ØÔ∫çÔªóÔ∫∏Ô∫é', 'Kazakh', false],
        ['Greenlandic', 'Greenlandic', false],
        ['·ûÅ·üí·ûò·üÇ·ûö', 'Cambodian/Khmer', false],
        ['‡≤ï‡≤®‡≥ç‡≤®‡≤°', 'Kannada', false],
        ['ÌïúÍµ≠Ïñ¥', 'Korean', false],
        ['‡§ï‡§æ‡§Ω‡§∂‡•Å‡§∞', 'Kashmiri', false],
        ['Kurd√≠', 'Kurdish', false],
        ['Kernewek', 'Cornish', false],
        ['–ö—ã—Ä–≥—ã–∑', 'Kirghiz', false],
        ['Latin', 'Latin', false],
        ['L√´tzebuergesch', 'Luxemburgish', false],
        ['Limburgs', 'Limburgish', false],
        ['Lingala', 'Lingala', false],
        ['‡∫û‡∫≤‡∫™‡∫≤‡∫•‡∫≤‡∫ß', 'Laotian', false],
        ['Lietuviskai', 'Lithuanian', false],
        ['Latvie≈°u', 'Latvian', false],
        ['Malagasy', 'Madagascarian', false],
        ['Maldives', 'Maldives', false],
        ['Maori', 'Maori', false],
        ['–ú–∞–∫–µ–¥–æ–Ω—Å–∫–∏', 'Macedonian', false],
        ['‡¥Æ‡¥≤‡¥Ø‡¥æ‡¥≥‡¥Ç', 'Malayalam', false],
        ['–ú–æ–Ω–≥–æ–ª', 'Mongolian', false],
        ['Moldavian', 'Moldavian', false],
        ['‡§Æ‡§∞‡§æ‡§†‡•Ä', 'Marathi', false],
        ['Bahasa Melayu', 'Malay', false],
        ['Malti', 'Maltese', false],
        ['Burmese', 'Burmese', false],
        ['Nauru', 'Nauruan', false],
        ['‡§®‡•á‡§™‡§æ‡§≤‡•Ä', 'Nepali', false],
        ['Nederlands', 'Dutch', false],
        ['Norsk', 'Norwegian', false],
        ['Nynorsk', 'Nynorsk', false],
        ['Occitan', 'Occitan', false],
        ['Oromo', 'Oromo', false],
        ['‡¨ì‡≠ú‡¨ø‡¨Ü', 'Oriya', false],
        ['‡®™‡©∞‡®ú‡®æ‡®¨‡©Ä', 'Punjabi', false],
        ['Polski', 'Polish', false],
        ['Ÿæ⁄öÿ™Ÿà', 'Pashto', false],
        ['Portugu√™s', 'Portuguese', false],
        ['Quechua', 'Quechua', false],
        ['Rhaeto-Romance', 'Rhaeto-Romance', false],
        ['Kirundi', 'Kirundi', false],
        ['Rom√¢nƒÉ', 'Romanian', false],
        ['–†—É—Å—Å–∫–∏–π', 'Russian', false],
        ['Kiyarwanda', 'Kiyarwanda', false],
        ['‡§∏‡§Ç‡§∏‡•ç‡§ï‡•É‡§§', 'Sanskrit', false],
        ['Sindhi', 'Sindhi', false],
#        ['Northern S√°mi', 'Northern S√°mi', false],
        ['Sangho', 'Sangho', false],
        ['Serbo-Croatian', 'Serbo-Croatian', false],
        ['Singhalese', 'Singhalese', false],
        ['Slovenƒçina', 'Slovak', false],
        ['Sloven≈°ƒçina', 'Slovenian', false],
        ['Samoan', 'Samoan', false],
        ['Shona', 'Shona', false],
        ['Somali', 'Somali', false],
        ['Shqip', 'Albanian', false],
        ['—Å—Ä–ø—Å–∫–∏', 'Serbian', false],
        ['Siswati', 'Siswati', false],
        ['Sesotho', 'Sesotho', false],
        ['Sudanese', 'Sudanese', false],
        ['Svenska', 'Swedish', false],
        ['Swahili', 'Swahili', false],
        ['‡Æ§‡ÆÆ‡Æø‡Æ¥', 'Tamil', false],
        ['‡∞§‡±Ü‡∞≤‡±Å‡∞ó‡±Å', 'Telugu', false],
        ['–¢–æ“∑–∏–∫–∏', 'Tadjik', false],
        ['‡πÑ‡∏ó‡∏¢', 'Thai', false],
        ['·âµ·åç·à≠·äõ', 'Tigrinya', false],
        ['—Ç“Ø—Ä–∫m–µ–Ω—á–µ', 'Turkmen', false],
        ['Tagalog', 'Tagalog', false],
        ['Setswana', 'Setswana', false],
        ['Tonga', 'Tonga', false],
        ['T√ºrk√ße', 'Turkish', false],
        ['Tsonga', 'Tsonga', false],
        ['—Ç–∞—Ç–∞—Ä—á–∞', 'Tatar', false],
        ['Twi', 'Twi', false],
        ['Uigur', 'Uigur', false],
        ['–£–∫—Ä–∞—ó–Ω—Å—å–∫–∞', 'Ukrainian', false],
        ['ÿßÿ±ÿØŸà', 'Urdu', false],
        ['–é–∑–±–µ–∫—á–∞', 'Uzbek', false],
        ['Ti·∫øng Vi·ªát', 'Vietnamese', false],
#        ['Volap√ºk', 'Volap√ºk', false],
        ['Walon', 'Walloon', false],
        ['Wolof', 'Wolof', false],
        ['isiXhosa', 'Xhosa', false],
        ['◊≤÷¥◊ì◊ô◊©', 'Yiddish', false],
        ['Yor√πb√°', 'Yorouba', false],
        ['Zhuang', 'Zhuang', false],
        ['zh-HK', 'Chinese - Traditional', false],
        ['zh-CN', 'Chinese - Simplified', false],
        ['isiZulu', 'Zulu', false]
      ].each {|l| BagPropertyEnum.create(:bag_property_id => other_languages_id, :value => l[1], :name => l[1]) }

      BagProperty.create(:name => 'address', :label => 'Address (for administrative purposes only)', :sort => 70, :default_visibility => BagProperty::VISIBILITY_ADMIN, :can_change_visibility => false)
      
      BagProperty.create(
        :name => 'city', 
        :label => 'City', 
        :data_type => BagProperty::DATA_TYPE_STRING,
        :display_type => BagProperty::DISPLAY_TYPE_TEXT, 
        :default_visibility => BagProperty::VISIBILITY_USERS, 
        :sort => 80 
      )

      BagProperty.create(
        :name => 'state', 
        :label => 'State / Province / District', 
        :data_type => BagProperty::DATA_TYPE_STRING,
        :display_type => BagProperty::DISPLAY_TYPE_TEXT, 
        :default_visibility => BagProperty::VISIBILITY_USERS, 
        :sort => 90 
      )

      BagProperty.create(
        :name => 'country', 
        :label => 'Country', 
        :data_type => BagProperty::DATA_TYPE_ENUM,
        :display_type => BagProperty::DISPLAY_TYPE_DROP_DOWN_LIST, 
        :default_visibility => BagProperty::VISIBILITY_EVERYONE,
        :can_change_visibility => false,
        :registration_page => 1,
        :required => true,
        :sort => 100 
      )
      country_id = BagProperty.find_by_name("country").id
      [
        ['AD', 'Andorra'],
        ['AE', 'United Arab Emirates'],
        ['AF', 'Afghanistan'],
        ['AG', 'Antigua and Barbuda'],
        ['AI', 'Anguilla'],
        ['AL', 'Albania'],
        ['AM', 'Armenia'],
        ['AN', 'Netherlands Antilles'],
        ['AO', 'Angola'],
        ['AQ', 'Antarctica'],
        ['AR', 'Argentina'],
        ['AS', 'American Samoa'],
        ['AU', 'Austria'],
        ['AS', 'Australia'],
        ['AW', 'Aruba'],
        ['AZ', 'Azerbaijan'],
        ['BA', 'Bosnia and Herzegovina'],
        ['BB', 'Barbados'],
        ['BD', 'Bangladesh'],
        ['BE', 'Belgium'],
        ['BF', 'Burkina Faso'],
        ['BH', 'Bahrain'],
        ['BI', 'Burundi'],
        ['BJ', 'Benin'],
        ['BM', 'Bermuda'],
        ['BO', 'Bolivia'],
        ['BR', 'Brazil'],
        ['BS', 'Bahamas'],
        ['BT', 'Bhutan'],
        ['BU', 'Bouvet Island'],
        ['BV', 'Bulgaria'],
        ['BW', 'Botswana'],
        ['BX', 'Brunei Darussalam'],
        ['BY', 'Belarus'],
        ['BZ', 'Belize'],
        ['CA', 'Canada'],
        ['CC', 'Cocos (Keeling) Islands'],
        ['CF', 'Central African Republic'],
        ['CG', 'Congo'],
        ['CH', 'Switzerland'],
        ['CI', 'Cote D\'Ivoire (Ivory Coast)'],
        ['CK', 'Cook Islands'],
        ['CL', 'Chile'],
        ['CM', 'Cameroon'],
        ['CN', 'China'],
        ['CO', 'Colombia'],
        ['CR', 'Costa Rica'],
        ['CU', 'Cuba'],
        ['CV', 'Cape Verde'],
        ['CX', 'Christmas Island'],
        ['CY', 'Cyprus'],
        ['CZ', 'Czech Republic'],
        ['DE', 'Germany'],
        ['DJ', 'Djibouti'],
        ['DK', 'Denmark'],
        ['DM', 'Dominica'],
        ['DO', 'Dominican Republic'],
        ['DZ', 'Algeria'],
        ['EC', 'Ecuador'],
        ['EE', 'Estonia'],
        ['EG', 'Egypt'],
        ['EH', 'Western Sahara'],
        ['ER', 'Eritrea'],
        ['ES', 'Spain'],
        ['ET', 'Ethiopia'],
        ['FI', 'Finland'],
        ['FJ', 'Fiji'],
        ['FK', 'Falkland Islands (Malvinas)'],
        ['FM', 'Micronesia'],
        ['FO', 'Faroe Islands'],
        ['FR', 'France'],
        ['GA', 'Gabon'],
        ['GB', 'Great Britain (UK)'],
        ['GD', 'Grenada'],
        ['GE', 'Georgia'],
        ['GF', 'French Guiana'],
        ['GH', 'Ghana'],
        ['GI', 'Gibraltar'],
        ['GL', 'Greenland'],
        ['GM', 'Gambia'],
        ['GN', 'Guinea'],
        ['GP', 'Guadeloupe'],
        ['GQ', 'Equatorial Guinea'],
        ['GR', 'Greece'],
        ['GS', 'South Georgia and South Sandwich Islands'],
        ['GT', 'Guatemala'],
        ['GU', 'Guam'],
        ['GW', 'Guinea-Bissau'],
        ['GY', 'Guyana'],
        ['HK', 'Hong Kong'],
        ['HM', 'Heard and McDonald Islands'],
        ['HN', 'Honduras'],
        ['HR', 'Croatia and Hrvatska'],
        ['HT', 'Haiti'],
        ['HU', 'Hungary'],
        ['ID', 'Indonesia'],
        ['IE', 'Ireland'],
        ['IL', 'Israel'],
        ['IN', 'India'],
        ['IO', 'British Indian Ocean Territory'],
        ['IQ', 'Iraq'],
        ['IR', 'Iran'],
        ['IS', 'Iceland'],
        ['IT', 'Italy'],
        ['JM', 'Jamaica'],
        ['JO', 'Jordan'],
        ['JP', 'Japan'],
        ['KE', 'Kenya'],
        ['KG', 'Kyrgyzstan'],
        ['KH', 'Cambodia'],
        ['KI', 'Kiribati'],
        ['KM', 'Comoros'],
        ['KN', 'Saint Kitts and Nevis'],
        ['KP', 'Korea North'],
        ['KR', 'Korea South'],
        ['KW', 'Kuwait'],
        ['KY', 'Cayman Islands'],
        ['KZ', 'Kazakhstan'],
        ['LA', 'Laos'],
        ['LB', 'Lebanon'],
        ['LC', 'Saint Lucia'],
        ['LI', 'Liechtenstein'],
        ['LK', 'Sri Lanka'],
        ['LR', 'Liberia'],
        ['LS', 'Lesotho'],
        ['LT', 'Lithuania'],
        ['LU', 'Luxembourg'],
        ['LV', 'Latvia'],
        ['LY', 'Libya'],
        ['MA', 'Morocco'],
        ['MC', 'Monaco'],
        ['MD', 'Moldova'],
        ['MG', 'Madagascar'],
        ['MH', 'Marshall Islands'],
        ['MK', 'Macedonia'],
        ['ML', 'Mali'],
        ['MM', 'Myanmar'],
        ['MN', 'Mongolia'],
        ['MO', 'Macau'],
        ['MP', 'Northern Mariana Islands'],
        ['MQ', 'Martinique'],
        ['MR', 'Mauritania'],
        ['MS', 'Montserrat'],
        ['MT', 'Malta'],
        ['MU', 'Mauritius'],
        ['MV', 'Maldives'],
        ['MW', 'Malawi'],
        ['MX', 'Mexico'],
        ['MY', 'Malaysia'],
        ['MZ', 'Mozambique'],
        ['NA', 'Namibia'],
        ['NC', 'New Caledonia'],
        ['NE', 'Niger'],
        ['NF', 'Norfolk Island'],
        ['NG', 'Nigeria'],
        ['NI', 'Nicaragua'],
        ['NE', 'Netherlands'],
        ['NO', 'Norway'],
        ['NP', 'Nepal'],
        ['NR', 'Nauru'],
        ['NU', 'Niue'],
        ['NZ', 'New Zealand'],
        ['OM', 'Oman'],
        ['PA', 'Panama'],
        ['PE', 'Peru'],
        ['PF', 'French Polynesia'],
        ['PG', 'Papua New Guinea'],
        ['PH', 'Philippines'],
        ['PK', 'Pakistan'],
        ['PO', 'Poland'],
        ['PM', 'St. Pierre and Miquelon'],
        ['PN', 'Pitcairn'],
        ['PR', 'Puerto Rico'],
        ['PT', 'Portugal'],
        ['PW', 'Palau'],
        ['PY', 'Paraguay'],
        ['QA', 'Qatar'],
        ['RE', 'Reunion'],
        ['RO', 'Romania'],
        ['RU', 'Russian Federation'],
        ['RW', 'Rwanda'],
        ['SA', 'Saudi Arabia'],
        ['SB', 'Solomon Islands'],
        ['SC', 'Seychelles'],
        ['SD', 'Sudan'],
        ['SE', 'Sweden'],
        ['SG', 'Singapore'],
        ['SH', 'St. Helena'],
        ['SI', 'Slovenia'],
        ['SJ', 'Svalbard and Jan Mayen Islands'],
        ['SK', 'Slovak Republic'],
        ['SL', 'Sierra Leone'],
        ['SM', 'San Marino'],
        ['SN', 'Senegal'],
        ['SO', 'Somalia'],
        ['SR', 'Suriname'],
        ['ST', 'Sao Tome and Principe'],
        ['SV', 'El Salvador'],
        ['SY', 'Syria'],
        ['SZ', 'Swaziland'],
        ['TC', 'Turks and Caicos Islands'],
        ['TD', 'Chad'],
        ['TF', 'French Southern Territories'],
        ['TG', 'Togo'],
        ['TH', 'Thailand'],
        ['TI', 'Tajikistan'],
        ['TK', 'Tokelau'],
        ['TM', 'Turkmenistan'],
        ['TN', 'Tunisia'],
        ['TO', 'Tonga'],
        ['TP', 'East Timor'],
        ['TR', 'Turkey'],
        ['TT', 'Trinidad and Tobago'],
        ['TV', 'Tuvalu'],
        ['TW', 'Taiwan'],
        ['TZ', 'Tanzania'],
        ['UA', 'Ukraine'],
        ['UG', 'Uganda'],
        ['UK', 'United Kingdom'],
        ['UM', 'US Minor Outlying Islands'],
        ['US', 'United States of America'],
        ['UY', 'Uruguay'],
        ['UZ', 'Uzbekistan'],
        ['VA', 'Vatican City State'],
        ['VC', 'Saint Vincent and the Grenadines'],
        ['VE', 'Venezuela'],
        ['VG', 'Virgin Islands (British)'],
        ['VN', 'Viet Nam'],
        ['VU', 'Vanuatu'],
        ['WF', 'Wallis and Futuna Islands'],
        ['WS', 'Samoa'],
        ['YE', 'Yemen'],
        ['YT', 'Mayotte'],
        ['YU', 'Yugoslavia'],
        ['ZA', 'South Africa'],
        ['ZM', 'Zambia'],
        ['ZR', 'Zaire'],
        ['ZW', 'Zimbabwe']
      ].each {|c| BagPropertyEnum.create(:bag_property_id => country_id, :value => c[1], :name => c[1]) }

#      BagProperty.create(
#        :name => 'state', 
#        :label => 'State', 
#        :data_type => BagProperty::DATA_TYPE_STRING,
#        :display_type => BagProperty::DISPLAY_TYPE_DROP_DOWN_LIST, 
#        :default_visibility => BagProperty::VISIBILITY_USERS, 
#        :sort => 4 
#      )
#      state_id = BagProperty.find_by_name("state").id
#
#      us_id = Country.find_by_name('United States of America (USA)').id
#      [
#        ['ALASKA', 'AK', us_id],
#        ['ALABAMA', 'AL', us_id],
#        ['ARKANSAS', 'AR', us_id],
#        ['AMERICAN SAMOA', 'AS', us_id],
#        ['ARIZONA', 'AZ', us_id],
#        ['CALIFORNIA', 'CA', us_id],
#        ['COLORADO', 'CO', us_id],
#        ['CONNECTICUT', 'CT', us_id],
#        ['DISTRICT OF COLUMBIA', 'DC', us_id],
#        ['WASHINGTON, DC', 'DC', us_id],
#        ['DELAWARE', 'DE', us_id],
#        ['FLORIDA', 'FL', us_id],
#        ['FEDERATED STATES OF MICRONESIA', 'FM', us_id],
#        ['GEORGIA', 'GA', us_id],
#        ['GUAM', 'GU', us_id],
#        ['HAWAII', 'HI', us_id],
#        ['IOWA', 'IA', us_id],
#        ['IDAHO', 'ID', us_id],
#        ['ILLINOIS', 'IL', us_id],
#        ['INDIANA', 'IN', us_id],
#        ['KANSAS', 'KS', us_id],
#        ['KENTUCKY', 'KY', us_id],
#        ['LOUISIANA', 'LA', us_id],
#        ['MASSACHUSETTS', 'MA', us_id],
#        ['MARYLAND', 'MD', us_id],
#        ['MAINE', 'ME', us_id],
#        ['MARSHALL ISLANDS', 'MH', us_id],
#        ['MICHIGAN', 'MI', us_id],
#        ['MINNESOTA', 'MN', us_id],
#        ['MISSOURI', 'MO', us_id],
#        ['NORTHERN MARIANA ISLANDS', 'MP', us_id],
#        ['MISSISSIPPI', 'MS', us_id],
#        ['MONTANA', 'MT', us_id],
#        ['NORTH CAROLINA', 'NC', us_id],
#        ['NORTH DAKOTA', 'ND', us_id],
#        ['NEBRASKA', 'NE', us_id],
#        ['NEW HAMPSHIRE', 'NH', us_id],
#        ['NEW JERSEY', 'NJ', us_id],
#        ['NEW MEXICO', 'NM', us_id],
#        ['NEVADA', 'NV', us_id],
#        ['NEW YORK', 'NY', us_id],
#        ['OHIO', 'OH', us_id],
#        ['OKLAHOMA', 'OK', us_id],
#        ['OREGON', 'OR', us_id],
#        ['PENNSYLVANIA', 'PA', us_id],
#        ['PUERTO RICO', 'PR', us_id],
#        ['PALAU', 'PW', us_id],
#        ['RHODE ISLAND', 'RI', us_id],
#        ['SOUTH CAROLINA', 'SC', us_id],
#        ['SOUTH DAKOTA', 'SD', us_id],
#        ['TENNESSEE', 'TN', us_id],
#        ['TEXAS', 'TX', us_id],
#        ['UTAH', 'UT', us_id],
#        ['VIRGINIA', 'VA', us_id],
#        ['VIRGIN ISLANDS', 'VI', us_id],
#        ['VERMONT', 'VT', us_id],
#        ['WASHINGTON', 'WA', us_id],
#        ['WISCONSIN', 'WI', us_id],
#        ['WEST VIRGINIA', 'WV', us_id],
#        ['WYOMING', 'WY', us_id]
#      ].each {|s| BagPropertyEnum.create(:bag_property_id => state_id, :value => s[0], :name => s[0]) }

      BagProperty.create(
        :name => 'zip', 
        :label => 'Postal Code', 
        :data_type => BagProperty::DATA_TYPE_STRING,
        :display_type => BagProperty::DISPLAY_TYPE_TEXT, 
        :default_visibility => BagProperty::VISIBILITY_ADMIN, 
        :sort => 110 
      )

      BagProperty.create(:name => 'phone', :label => 'Phone', :sort => 115, :default_visibility => BagProperty::VISIBILITY_ADMIN) 

      BagProperty.create(
        :name => 'organization', 
        :label => 'School District / University / Company', 
        :data_type => BagProperty::DATA_TYPE_STRING,
        :display_type => BagProperty::DISPLAY_TYPE_TEXT, 
        :default_visibility => BagProperty::VISIBILITY_USERS, 
        :sort => 120 
      )
      
      BagProperty.create(
        :name => 'teaching_experience', 
        :label => 'Grade Level Teaching Experience', 
        :data_type => BagProperty::DATA_TYPE_ENUM,
        :display_type => BagProperty::DISPLAY_TYPE_CHECK_BOX_LIST, 
        :default_visibility => BagProperty::VISIBILITY_USERS,
        :height => 114,
        :sort => 130
      )
      teaching_experience_id = BagProperty.find_by_name("teaching_experience").id
      [
        ["prek", "Pre Grade 1", 10],
        ["grade school", "Grades 1 to 3", 20],
        ["grade_4-6", "Grades 4 to 6", 30],
        ["grade_7", "Grade 7", 40],
        ["grade_8", "Grade 8", 50],
        ["high school", "Grade 9", 60],
        ["grade_10", "Grade 10", 70],
        ["grade_11", "Grade 11", 80],
        ["grade_12", "Grade 12", 90],
        ["college", "College/University", 100],
        ["adult", "Adult Education", 110],
        ["none", "None", 120]
      ].each {|te| BagPropertyEnum.create(:bag_property_id => teaching_experience_id, :value => te[0], :name => te[1], :sort => te[2]) }
      
      BagProperty.create(:name => 'skills', :label => 'Skills', :data_type => BagProperty::DATA_TYPE_TEXT, :display_type => BagProperty::DISPLAY_TYPE_TEXT_AREA, :sort => 140) 
      BagProperty.create(:name => 'occupation', :label => 'Occupation', :data_type => BagProperty::DATA_TYPE_TEXT, :display_type => BagProperty::DISPLAY_TYPE_TEXT_AREA, :sort => 150) 
      
      BagProperty.create(:name => 'website', :label => 'Website', :sort => 160, :is_link => true) 
      BagProperty.create(:name => 'blog', :label => 'Blog', :sort => 170, :is_link => true) 
      BagProperty.create(:default_visibility => BagProperty::VISIBILITY_FRIENDS, :name => 'youtube_username', :label => 'Youtube Username', :sort => 180, :is_link => true) 
      BagProperty.create(:default_visibility => BagProperty::VISIBILITY_FRIENDS, :name => 'flickr_username', :label => 'Flickr Username', :sort => 190, :is_link => true) 
      BagProperty.create(:default_visibility => BagProperty::VISIBILITY_FRIENDS, :name => 'aim_name', :label => 'AOL Instant Messenger', :sort => 200, :is_link => true, :prefix => 'aim:goim?screenname=') 
      BagProperty.create(:default_visibility => BagProperty::VISIBILITY_FRIENDS, :name => 'msn', :label => 'MSN Messenger', :sort => 210, :is_link => true, :prefix => 'http://members.msn.com/') 
      BagProperty.create(:default_visibility => BagProperty::VISIBILITY_FRIENDS, :name => 'skype', :label => 'Skype', :sort => 220, :is_link => true, :prefix => 'skype:') 
      BagProperty.create(:default_visibility => BagProperty::VISIBILITY_FRIENDS, :name => 'yahoo', :label => 'Yahoo! Messenger', :sort => 230, :is_link => true, :prefix => 'ymsgr:sendIM?') 
      BagProperty.create(:default_visibility => BagProperty::VISIBILITY_FRIENDS, :name => 'gtalk_name', :label => 'GTalk', :sort => 240, :is_link => true, :prefix => 'xmpp:') 
      BagProperty.create(:default_visibility => BagProperty::VISIBILITY_FRIENDS, :name => 'ichat_name', :label => 'iChat', :sort => 250, :is_link => true, :prefix => 'ichat:')
      
#      BagProperty.create(:name => 'share_doc', :label => 'Share a Web Page or Google Doc with Me', :display_type => BagProperty::DISPLAY_TYPE_OPTION, :sort => 320)
      
      puts 'Done adding twb profile fields!'
    end
  end

  namespace :db do
    desc "Add profile visibility options to the database"
    task :add_visibility_options => :environment do
      BagProperty.create(:name => 'view_blog', :label => 'My Blog Posts', :default_visibility => BagProperty::VISIBILITY_FRIENDS, :display_type => BagProperty::DISPLAY_TYPE_OPTION, :sort => 260)
      BagProperty.create(:name => 'view_photos', :label => 'My Photos', :default_visibility => BagProperty::VISIBILITY_FRIENDS, :display_type => BagProperty::DISPLAY_TYPE_OPTION, :sort => 270)
      BagProperty.create(:name => 'view_groups', :label => 'My Groups', :default_visibility => BagProperty::VISIBILITY_FRIENDS, :display_type => BagProperty::DISPLAY_TYPE_OPTION, :sort => 280)
      BagProperty.create(:name => 'view_colleagues', :label => 'My Colleagues', :default_visibility => BagProperty::VISIBILITY_FRIENDS, :display_type => BagProperty::DISPLAY_TYPE_OPTION, :sort => 290)
      BagProperty.create(:name => 'view_activities', :label => 'My Recent Activity Feed', :default_visibility => BagProperty::VISIBILITY_FRIENDS, :display_type => BagProperty::DISPLAY_TYPE_OPTION, :sort => 300)
      bp = BagProperty.create(:name => 'view_comments', :label => 'Comments On My Profile', :default_visibility => BagProperty::VISIBILITY_USERS, :display_type => BagProperty::DISPLAY_TYPE_OPTION, :sort => 305)
      BagProperty.create(:name => 'view_shares', :label => 'Items I Have Shared', :default_visibility => BagProperty::VISIBILITY_FRIENDS, :display_type => BagProperty::DISPLAY_TYPE_OPTION, :sort => 307)
      BagProperty.create(:name => 'direct_message', :label => 'Direct Message', :default_visibility => BagProperty::VISIBILITY_FRIENDS, :display_type => BagProperty::DISPLAY_TYPE_OPTION, :sort => 310)
      User.find(:all).each do |user|
        BagPropertyValue.create(:user_id => user.id, 
          :bag_property_id => bp.id,   
          :visibility => BagProperty::VISIBILITY_USERS)
      end
      
      puts 'Done adding profile visibility options'
    end
  end
    
  namespace :db do
    desc "Add fields required by TWB canada"
    task :add_canada_fields => :environment do
      bp = BagProperty.create(
        :name => 'teaching_license', 
        :label => 'Do you have an official license to teach?', 
        :data_type => BagProperty::DATA_TYPE_ENUM,
        :display_type => BagProperty::DISPLAY_TYPE_RADIO, 
        :required => false, 
        :default_visibility => BagProperty::VISIBILITY_USERS,
        :sort => 92 
      )
      [
        ['Yes','yes',10],
        ['No','no',20],
        ['Pending','pending',30],
        ['Other','other',40]
      ].each {|c| BagPropertyEnum.create(:bag_property_id => bp.id, :value => c[1], :name => c[0], :sort => c[2]) }
      BagProperty.create(:name => 'subject_areas', :label => 'Subject area(s) for which you are licensed', :default_visibility => BagProperty::VISIBILITY_USERS, :data_type => BagProperty::DATA_TYPE_TEXT, :display_type => BagProperty::DISPLAY_TYPE_TEXT_AREA, :sort => 94, :registration_page => 1, :required => false, :can_change_visibility => false, :maxlength => 250) 
      bp = BagProperty.create(
        :name => 'yrs_teaching_experience', 
        :label => 'Number of years teaching experience', 
        :data_type => BagProperty::DATA_TYPE_ENUM,
        :display_type => BagProperty::DISPLAY_TYPE_RADIO, 
        :required => false, 
        :default_visibility => BagProperty::VISIBILITY_USERS,
        :sort => 96 
      )
      [
        ['Less than one','months',10],
        ['1-4','1-4',20],
        ['5-10','5-10',30],
        ['11-15','11-15',40],
        ['16-20','16-20',50],
        ['Greater than 20','more_than_20',60],
        ['None','none',70]
      ].each {|c| BagPropertyEnum.create(:bag_property_id => bp.id, :value => c[1], :name => c[0], :sort => c[2]) }
      bp = BagProperty.create(
        :name => 'twb_canada', 
        :label => 'I am also registered on the TWB Canada Network:', 
        :data_type => BagProperty::DATA_TYPE_ENUM,
        :display_type => BagProperty::DISPLAY_TYPE_RADIO, 
        :required => false, 
        :default_visibility => BagProperty::VISIBILITY_USERS,
        :sort => 155 
      )
      [
        ['Yes','yes',10],
        ['No','no',20],
        ['Would like more information','wants_more_info',30]
      ].each {|c| BagPropertyEnum.create(:bag_property_id => bp.id, :value => c[1], :name => c[0], :sort => c[2]) }
      puts 'Done'
    end
  end
end

