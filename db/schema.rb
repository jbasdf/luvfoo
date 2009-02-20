# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090213002439) do

  create_table "bag_properties", :force => true do |t|
    t.integer "bag_id",                :default => 1
    t.string  "name"
    t.string  "label"
    t.integer "data_type",             :default => 1
    t.string  "display_type",          :default => "text"
    t.boolean "required",              :default => false
    t.string  "default_value"
    t.integer "default_visibility",    :default => 4
    t.boolean "can_change_visibility", :default => true
    t.integer "sort",                  :default => 9999
    t.integer "width",                 :default => -1
    t.integer "height",                :default => -1
    t.integer "registration_page"
    t.string  "sf_field"
    t.boolean "is_link",               :default => false
    t.string  "prefix"
    t.integer "maxlength",             :default => 5000
  end

  create_table "bag_property_enums", :force => true do |t|
    t.integer "bag_property_id"
    t.string  "name"
    t.string  "value"
    t.integer "sort"
  end

  add_index "bag_property_enums", ["bag_property_id"], :name => "index_bag_property_enums_on_bag_property_id"

  create_table "bag_property_values", :force => true do |t|
    t.integer  "data_type",                                :default => 1
    t.integer  "user_id"
    t.integer  "bag_property_id"
    t.string   "svalue"
    t.text     "tvalue",               :limit => 16777215
    t.integer  "ivalue"
    t.integer  "bag_property_enum_id"
    t.datetime "tsvalue"
    t.integer  "visibility"
  end

  add_index "bag_property_values", ["user_id", "bag_property_id"], :name => "index_bag_property_values_on_user_id_and_bag_property_id"

  create_table "blogs", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "blogs", ["user_id"], :name => "index_blogs_on_user_id"

  create_table "comments", :force => true do |t|
    t.text     "comment"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.integer  "user_id"
    t.string   "commentable_type", :default => "",    :null => false
    t.integer  "commentable_id",                      :null => false
    t.integer  "is_denied",        :default => 0,     :null => false
    t.boolean  "is_reviewed",      :default => false
  end

  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"
  add_index "comments", ["commentable_id", "commentable_type"], :name => "index_comments_on_commentable_id_and_commentable_type"

  create_table "content_page_versions", :force => true do |t|
    t.integer  "content_page_id"
    t.integer  "version"
    t.integer  "creator_id"
    t.string   "title"
    t.string   "url_key"
    t.text     "body"
    t.string   "locale"
    t.datetime "updated_at"
    t.text     "body_raw"
    t.integer  "contentable_id"
    t.string   "contentable_type"
    t.integer  "parent_id",        :default => 0
  end

  create_table "content_pages", :force => true do |t|
    t.integer  "creator_id"
    t.string   "title"
    t.string   "url_key"
    t.text     "body"
    t.string   "locale"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "body_raw"
    t.integer  "contentable_id"
    t.string   "contentable_type"
    t.integer  "parent_id",        :default => 0, :null => false
    t.integer  "version"
  end

  add_index "content_pages", ["parent_id"], :name => "index_content_pages_on_parent_id"

  create_table "countries", :force => true do |t|
    t.string "name",         :limit => 128, :default => "", :null => false
    t.string "abbreviation", :limit => 3,   :default => "", :null => false
  end

  create_table "entries", :force => true do |t|
    t.string   "permalink",    :limit => 2083
    t.string   "title"
    t.text     "body"
    t.datetime "published_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "google_doc",                   :default => false
    t.boolean  "displayable",                  :default => false
  end

  create_table "event_users", :force => true do |t|
    t.integer  "user_id"
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "event_users", ["user_id"], :name => "index_event_users_on_user_id"
  add_index "event_users", ["event_id"], :name => "index_event_users_on_event_id"

  create_table "events", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.datetime "start_at"
    t.datetime "end_at"
    t.string   "summary"
    t.string   "location"
    t.text     "description"
    t.text     "uri"
    t.integer  "eventable_id"
    t.string   "eventable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "attendees_count", :default => 0, :null => false
  end

  create_table "feed_items", :force => true do |t|
    t.boolean  "include_comments", :default => false, :null => false
    t.boolean  "is_public",        :default => false, :null => false
    t.integer  "item_id"
    t.string   "item_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "html_cache"
    t.integer  "creator_id"
    t.string   "template"
  end

  add_index "feed_items", ["item_id", "item_type"], :name => "index_feed_items_on_item_id_and_item_type"

  create_table "feeds", :force => true do |t|
    t.integer "ownable_id"
    t.integer "feed_item_id"
    t.string  "ownable_type"
  end

  add_index "feeds", ["ownable_id", "feed_item_id"], :name => "index_feeds_on_user_id_and_feed_item_id"

  create_table "forums", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "forumable_type"
    t.integer  "forumable_id"
    t.string   "url_key"
    t.text     "description_html"
    t.integer  "topics_count",     :default => 0
    t.integer  "posts_count",      :default => 0
  end

  add_index "forums", ["url_key"], :name => "index_forums_on_url_key"

  create_table "friends", :force => true do |t|
    t.integer  "inviter_id"
    t.integer  "invited_id"
    t.integer  "status",     :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "friends", ["inviter_id", "invited_id"], :name => "index_friends_on_inviter_id_and_invited_id", :unique => true
  add_index "friends", ["invited_id", "inviter_id"], :name => "index_friends_on_invited_id_and_inviter_id", :unique => true

  create_table "grade_level_experiences", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "grade_level_experiences_users", :id => false, :force => true do |t|
    t.integer  "user_id"
    t.integer  "grade_level_experience_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", :force => true do |t|
    t.integer  "creator_id"
    t.string   "name"
    t.text     "description"
    t.string   "icon"
    t.string   "state"
    t.string   "url_key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "default_role",              :default => "member"
    t.integer  "visibility",                :default => 2
    t.boolean  "requires_approval_to_join", :default => false
    t.integer  "member_count"
  end

  add_index "groups", ["url_key"], :name => "index_groups_on_url_key"
  add_index "groups", ["creator_id"], :name => "index_groups_on_creator_id"

  create_table "interests", :force => true do |t|
    t.string "name"
  end

  create_table "interests_users", :id => false, :force => true do |t|
    t.integer  "user_id"
    t.integer  "interest_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "interests_users", ["user_id", "interest_id"], :name => "index_interests_users_on_user_id_and_interest_id"
  add_index "interests_users", ["user_id"], :name => "index_interests_users_on_user_id"

  create_table "languages", :force => true do |t|
    t.string  "name"
    t.string  "english_name"
    t.integer "is_default",   :default => 0
  end

  create_table "languages_users", :id => false, :force => true do |t|
    t.integer  "user_id"
    t.integer  "language_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "logos", :force => true do |t|
    t.integer  "site_id"
    t.integer  "parent_id"
    t.integer  "user_id"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.string   "content_type"
    t.string   "filename"
    t.string   "thumbnail"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "logos", ["site_id"], :name => "index_logos_on_site_id"
  add_index "logos", ["parent_id"], :name => "index_logos_on_parent_id"
  add_index "logos", ["user_id"], :name => "index_logos_on_user_id"
  add_index "logos", ["content_type"], :name => "index_logos_on_content_type"

  create_table "membership_requests", :force => true do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "memberships", :force => true do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.boolean  "banned",     :default => false
    t.string   "role",       :default => "--- :member\n"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", :force => true do |t|
    t.string   "subject"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.boolean  "read",        :default => false, :null => false
  end

  add_index "messages", ["sender_id"], :name => "index_messages_on_sender_id"
  add_index "messages", ["receiver_id"], :name => "index_messages_on_receiver_id"

  create_table "moderatorships", :force => true do |t|
    t.integer "forum_id"
    t.integer "user_id"
  end

  add_index "moderatorships", ["forum_id"], :name => "index_moderatorships_on_forum_id"

  create_table "monitorships", :force => true do |t|
    t.integer "topic_id"
    t.integer "user_id"
    t.boolean "active",   :default => true
  end

  create_table "news_items", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "newsable_id"
    t.string   "newsable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url_key"
    t.string   "icon"
    t.integer  "creator_id"
  end

  add_index "news_items", ["url_key"], :name => "index_news_items_on_url_key"

  create_table "open_id_authentication_associations", :force => true do |t|
    t.integer "issued"
    t.integer "lifetime"
    t.string  "handle"
    t.string  "assoc_type"
    t.binary  "server_url"
    t.binary  "secret"
  end

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.integer "timestamp",  :null => false
    t.string  "server_url"
    t.string  "salt",       :null => false
  end

  create_table "permissions", :force => true do |t|
    t.integer  "role_id",    :null => false
    t.integer  "user_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photos", :force => true do |t|
    t.string   "caption",        :limit => 1000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "photoable_id"
    t.string   "image"
    t.string   "photoable_type"
    t.integer  "creator_id"
  end

  add_index "photos", ["photoable_id"], :name => "index_photos_on_user_id"

  create_table "plone_group_roles", :force => true do |t|
    t.string   "login"
    t.string   "rolename"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plone_open_roles", :force => true do |t|
    t.string   "login"
    t.string   "rolename"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "posts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "topic_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "forum_id"
    t.text     "body_html"
  end

  add_index "posts", ["forum_id", "created_at"], :name => "index_posts_on_forum_id"
  add_index "posts", ["user_id", "created_at"], :name => "index_posts_on_user_id"
  add_index "posts", ["topic_id", "created_at"], :name => "index_posts_on_topic_id"

  create_table "professional_roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "rolename"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "shared_entries", :force => true do |t|
    t.integer  "shared_by_id"
    t.integer  "entry_id"
    t.string   "destination_type", :default => "",    :null => false
    t.integer  "destination_id",                      :null => false
    t.datetime "created_at"
    t.boolean  "can_edit",         :default => false
    t.boolean  "public",           :default => false
  end

  create_table "shared_pages", :force => true do |t|
    t.integer  "content_page_id"
    t.string   "share_type",      :default => "", :null => false
    t.integer  "share_id",                        :null => false
    t.integer  "status",          :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shared_uploads", :force => true do |t|
    t.integer  "shared_uploadable_id"
    t.string   "shared_uploadable_type"
    t.integer  "upload_id"
    t.integer  "shared_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shared_uploads", ["shared_uploadable_id"], :name => "index_shared_uploads_on_uploadable_id"
  add_index "shared_uploads", ["upload_id"], :name => "index_shared_uploads_on_upload_id"
  add_index "shared_uploads", ["shared_by_id"], :name => "index_shared_uploads_on_shared_by_id"

  create_table "sites", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",                        :default => "", :null => false
    t.string   "subtitle",                     :default => "", :null => false
    t.string   "slogan",                       :default => "", :null => false
    t.string   "background_color",             :default => "", :null => false
    t.string   "font_color",                   :default => "", :null => false
    t.string   "font_style",                   :default => "", :null => false
    t.string   "font_size",                    :default => "", :null => false
    t.string   "content_background_color",     :default => "", :null => false
    t.string   "a_font_style",                 :default => "", :null => false
    t.string   "a_font_color",                 :default => "", :null => false
    t.string   "top_background_color",         :default => "", :null => false
    t.string   "top_color",                    :default => "", :null => false
    t.string   "link_button_background_color"
    t.string   "link_button_font_color"
    t.string   "highlight_color"
  end

  create_table "states", :force => true do |t|
    t.string  "name",         :limit => 128, :default => "", :null => false
    t.string  "abbreviation", :limit => 3,   :default => "", :null => false
    t.integer "country_id",   :limit => 8,                   :null => false
  end

  add_index "states", ["country_id"], :name => "country_id"

  create_table "status_updates", :force => true do |t|
    t.integer  "user_id"
    t.string   "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "taggable_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "topics", :force => true do |t|
    t.integer  "forum_id"
    t.integer  "user_id"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "hits",         :default => 0
    t.integer  "sticky",       :default => 0
    t.integer  "posts_count",  :default => 0
    t.datetime "replied_at"
    t.boolean  "locked",       :default => false
    t.integer  "replied_by"
    t.integer  "last_post_id"
  end

  add_index "topics", ["forum_id"], :name => "index_topics_on_forum_id"
  add_index "topics", ["forum_id", "sticky", "replied_at"], :name => "index_topics_on_sticky_and_replied_at"
  add_index "topics", ["forum_id", "replied_at"], :name => "index_topics_on_forum_id_and_replied_at"

  create_table "uploads", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "user_id"
    t.string   "content_type"
    t.string   "name"
    t.string   "caption",         :limit => 1000
    t.text     "description"
    t.string   "filename"
    t.string   "thumbnail"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_public",                       :default => true
    t.integer  "uploadable_id"
    t.string   "uploadable_type"
  end

  add_index "uploads", ["parent_id"], :name => "index_uploads_on_parent_id"
  add_index "uploads", ["user_id"], :name => "index_uploads_on_user_id"
  add_index "uploads", ["content_type"], :name => "index_uploads_on_content_type"

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "password_reset_code",       :limit => 40
    t.boolean  "enabled",                                 :default => true
    t.boolean  "terms_of_service",                        :default => false, :null => false
    t.boolean  "can_send_messages",                       :default => true
    t.string   "time_zone",                               :default => "UTC"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "website"
    t.string   "blog"
    t.string   "flickr"
    t.text     "about_me"
    t.string   "aim_name"
    t.string   "gtalk_name"
    t.string   "ichat_name"
    t.string   "icon"
    t.string   "location"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_active",                               :default => false
    t.string   "youtube_username"
    t.string   "flickr_username"
    t.string   "identity_url"
    t.string   "city"
    t.integer  "state_id"
    t.string   "zip"
    t.integer  "country_id"
    t.string   "phone"
    t.string   "phone2"
    t.string   "msn"
    t.string   "skype"
    t.string   "yahoo"
    t.string   "organization"
    t.integer  "grade_experience"
    t.integer  "language_id"
    t.text     "why_joined"
    t.text     "skills"
    t.text     "occupation"
    t.string   "plone_password",            :limit => 40
    t.string   "tmp_password",              :limit => 40
    t.integer  "professional_role_id"
    t.string   "blog_rss"
    t.text     "protected_profile"
    t.text     "public_profile"
    t.integer  "posts_count",                             :default => 0
    t.datetime "last_seen_at"
    t.string   "api_key"
  end

  add_index "users", ["login"], :name => "index_users_on_login"
  add_index "users", ["api_key"], :name => "index_users_on_api_key"

  create_table "users_languages", :force => true do |t|
    t.integer "user_id"
    t.integer "language_id"
  end

  add_index "users_languages", ["user_id", "language_id"], :name => "index_users_languages_on_user_id_and_language_id"
  add_index "users_languages", ["user_id"], :name => "index_users_languages_on_user_id"

  create_table "widgets", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
