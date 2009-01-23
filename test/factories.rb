Factory.sequence :email do |n|
  "somebody#{n}@example.com"
end

Factory.sequence :login do |n|
  "inquire#{n}"
end

Factory.sequence :name do |n|
  "a_name#{n}"
end

Factory.sequence :abbr do |n|
  "abbr#{n}"
end

Factory.sequence :description do |n|
  "This is the description: #{n}"
end

Factory.define :state do |f|
  f.name { Factory.next(:name) }
  f.abbreviation { Factory.next(:abbr) }
  f.country {|a| a.association(:country) }
end

Factory.define :country do |f|
  f.name { Factory.next(:name) }
  f.abbreviation { Factory.next(:abbr) }
end

Factory.define :language do |f|
  f.name { Factory.next(:name) }
  f.english_name { Factory.next(:name) }
end

Factory.define :user do |f|
  f.login { Factory.next(:login) }
  f.email { Factory.next(:email) }
  f.password 'inquire_pass'
  f.password_confirmation 'inquire_pass'
  f.first_name 'test'
  f.last_name 'guy'
  f.country {|a| a.association(:country)}
  f.language {|a| a.association(:language)}  
  f.terms_of_service true
end

Factory.define :group do |f|
  f.name { Factory.next(:name) }
  f.description { Factory.next(:description) }
  f.creator {|a| a.association(:user)}
end

Factory.define :membership do |f|
  f.group {|a| a.association(:group)}
  f.user {|a| a.association(:user)}
  f.banned false
  f.role {|m| m.group.default_role}
end

Factory.define :entry do |f|
  f.permalink 'http://www.luvfoo.com'
  f.title 'entry title'
  f.body 'entry body'
  f.published_at Time.now
  f.user {|a| a.association(:user)}
end 

Factory.define :news_item do |f|
  f.title 'new news post'
  f.body 'the body'
  f.creator {|a| a.association(:user)}
  f.newsable {|a| a.association(:user)}
end

Factory.define :content_page do |f|
  f.creator {|a| a.association(:user)}
  f.title { Factory.next(:name) }
  f.body_raw { Factory.next(:description) }
end

Factory.define :upload do |f|
  f.user {|a| a.association(:user)}
  f.uploadable {|a| a.association(:group)}
  f.content_type 'image/jpeg'
  f.filename 'test.jpg'
  f.size 10000
  f.is_public true
end

Factory.define :shared_upload do |f|
  f.shared_uploadable {|a| a.association(:user)}
  f.upload {|a| a.association(:upload)}
  f.shared_by {|a| a.association(:user)}
end

Factory.define :message do |f|
  f.subject { Factory.next(:name) }  
  f.body { Factory.next(:description) }    
  f.sender {|a| a.association(:user)}
  f.receiver {|a| a.association(:user)}
  f.read false
end

Factory.define :event do |f|
  f.title { Factory.next(:name) }  
  f.summary
  f.location
  f.description{ Factory.next(:description) }
  f.eventable
  f.start_at { DateTime.now + 2.days }
  f.end_at { DateTime.now + 3.days }
  f.user {|a| a.association(:user)}
end

Factory.define :status_update do |f|
  f.user {|a| a.association(:user)}
  f.text { Factory.next(:description) }
end

Factory.define :permission do |f|
  f.role {|a| a.association(:role)}
  f.user {|a| a.association(:user)}
end

Factory.define :role do |f|
  f.rolename { Factory.next(:name) }
end

Factory.define :forum do |f|
  f.name { Factory.next(:name) }
  f.description { Factory.next(:description) }
end

Factory.define :post do |f|
  f.user {|a| a.association(:user)}
  f.body { Factory.next(:description) }
  f.topic { Factory.next(:name) }
end

Factory.define :topic do |f|
  f.user {|a| a.association(:user)}
  f.forum {|a| a.association(:forum)}
  f.title { Factory.next(:name) }
end
