ActionController::Routing::Routes.draw do |map|

#  map.root :controller => 'home', :action => 'index'

  # home
  map.with_options(:controller => 'home') do |home|
    home.home '/home', :action => 'home'
    home.latest_comments '/latest_comments.rss', :action => 'latest_comments', :format=>'rss'
    home.newest_members '/newest_members.rss', :action => 'newest_members', :format=>'rss'
    home.sitemap '/sitemap', :action => 'sitemap'
    home.contact '/contact', :action => 'contact'
    home.me '/me', :action => 'me'
  end

  #    map.new_site_page '/page/new', :controller => 'page', :action => 'new'
  #    map.edit_site_page '/page/:locale/*content_page/edit', :controller => 'page', :action => 'edit'
  #    map.update_site_page '/page/:locale/*content_page/update', :controller => 'page', :action => 'update'
  #    map.site_page '/page/:locale/*content_page', :controller => 'page', :action => 'show_site_page'
  #    map.create_site_page '/page', :controller => 'page', :action => 'create'

  # users
  map.resources :users, :has_many => [:friends, :feed_items, :messages, :roles, :page, :shared_uploads, :moderators, :posts],
                        :member => { :enable => :put, :help => :get, :welcome => :get, :delete_icon => :delete }, 
                        :collection => { :is_login_available => :post, :is_email_available => :post } do |users|
    users.resource :account
    users.resources :blogs, :controller => 'users/blogs'
    users.resources :groups, :controller => 'users/groups'
    users.resources :photos, :controller => 'users/photos'
    users.resources :invites, :controller => 'users/invites'
    users.resources :uploads, :controller => 'users/uploads', :collection => { :photos => :get }, 
                                                              :has_many => [:shared_uploads]
    users.resources :entries, :controller => 'users/entries'
    users.resources :shared_entries, :controller => 'users/shared_entries'
    users.resources :status_updates, :controller => 'users/status_updates'    
  end

  map.resources :shared_uploads, :collection => { :for_me => :get, :for_group => :get }

  map.resources :news
  
  # Content pages (put them in the content/pages/<locale>/ directory)
  # These pages will render ruby code
  map.resources :pages
  map.content '/page/*content_page', :controller => 'content', :action => 'show_page'
  map.content '/content/*content_page', :controller => 'content', :action => 'show_page'
  map.protected_page '/protected/*content_page', :controller => 'content', :action => 'show_protected_page'

  map.with_options(:controller => 'users') do |users| 
    users.signup  "/signup",  :action => 'new'
  end

  map.with_options(:controller => 'accounts') do |accounts|
    accounts.activate "/activate/:id",   :action => 'show'
    accounts.change_password '/change_password', :action => 'edit'
  end

  map.resource :password
  map.with_options(:controller => 'passwords') do |passwords|
    passwords.forgot_password "/forgot_password", :action => 'new'
    passwords.reset_password "/reset_password/:id", :action => 'edit'
  end    

  map.resources :profiles, :collection => { :search => :get }, :member => {:cache => :get} do |profiles|
    profiles.resources :comments, :controller => 'profiles/comments'
    profiles.resources :blogs, :controller => 'profiles/blogs' do |blogs|
      blogs.resources :comments
    end
  end
  

  # groups
  map.resources :groups, :collection => { :search => :get },  :member => { :delete_icon => :post, :update_memberships_in => :post } do |group|
    group.resources :memberships, :controller => 'groups/memberships'
    group.resources :admin, :controller => 'groups/admin'
    group.resources :photos, :controller => 'groups/photos'
    group.resources :news, :controller => 'groups/news' do |news|
      news.resources :comments
    end
    group.resources :activities, :controller => 'groups/activities'
    group.resources :forums, :controller => 'groups/forums', :has_many => [:topics]
    group.resources :comments, :controller => 'groups/comments'
    group.resources :invites, :controller => 'groups/invites'
    group.resources :shared_entries, :controller => 'groups/shared_entries'
    group.resources :uploads, :controller => 'groups/uploads', :collection => { :photos => :get }, 
                                                               :has_many => [:shared_uploads]
  end

  # forums
  map.resources :posts, :name_prefix => 'all_', :collection => { :search => :get }
	map.resources :forums, :topics, :posts, :monitorship

  %w(forum).each do |attr|
    map.resources :posts, :name_prefix => "#{attr}_", :path_prefix => "/#{attr.pluralize}/:#{attr}_id"
  end
  
  map.resources :forums do |forum|
    forum.resources :topics do |topic|
      topic.resources :posts
      topic.resource :monitorship, :controller => :monitorships
    end
  end
  
  # sessions
  map.resource :session
  map.with_options(:controller => 'sessions') do |sessions|
    sessions.login "/login", :action => 'new'
    sessions.logout "/logout", :action => 'destroy'
    sessions.open_id_complete 'session', :action => "create", :requirements => { :method => :get }
  end

  # admin
  map.namespace :admin do |a|
    a.home '/', :controller => 'home', :action => 'index'
    a.resources :users, :collection => { :inactive => :get, :inactive_emails => :get, :activate_all => :get, :search => :get, :do_search => :post }
    a.resources :roles
    a.resources :permissions
    a.resources :sites
    a.resources :news_items
    a.resources :member_stories
    a.resources :pages, :collection => { :images => :get, :files => :get }, :member => { :children => :get }
  end

  # messages
  map.resources :messages, :collection => { :sent => :get, :destroy => :post }

  # Member stories
  map.resources :member_stories, :has_many => :comments

  # comments
  map.resources :comments

  #uploads 
  map.resources :uploads, :collection => { :swfupload => :post },
                          :member => { :google_upload => :get }
  
  # forums
  map.resources :forums, :collection => {:update_positions => :post} do |forum|
    forum.resources :topics, :controller => :forum_topics do |topic|
      topic.resources :posts, :controller => :forum_posts
    end
  end

  # share page
  #map.resources :entries
  map.connect '/share', :controller => 'users/shared_entries', :action => 'new'
  
  map.connect '/search', :controller => 'search', :action => 'index'
  
  map.photos 'photos', :controller => 'site_photos', :action => 'index'

  #    map.group_page '/groups/:group_id/page/:locale/*content_page', :controller => 'page', :action => 'show_group_page'

  #    map.edit_user_page '/users/:user_id/page/:locale/*content_page/edit', :controller => 'page', :action => 'edit'
  #    map.update_user_page '/users/:user_id/page/:locale/*content_page/update', :controller => 'page', :action => 'update'
  #    map.user_page '/users/:user_id/page/:locale/*content_page', :controller => 'page', :action => 'show_user_page'

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action.:format'
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
