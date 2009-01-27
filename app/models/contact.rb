# == Schema Information
# Schema version: 20090123074335
#
# Table name: contacts
#
#  id                           :text(18)      not null, primary key
#  is_deleted                   :boolean(0)    not null
#  master_record_id             :text(18)      not null
#  account_id                   :text(18)      not null
#  last_name                    :text(80)      not null
#  first_name                   :text(40)      not null
#  salutation                   :text(40)      not null
#  name                         :text(121)     not null
#  record_type_id               :text(18)      not null
#  other_street                 :text(255)     not null
#  other_city                   :text(40)      not null
#  other_state                  :text(20)      not null
#  other_postal_code            :text(20)      not null
#  other_country                :text(40)      not null
#  mailing_street               :text(255)     not null
#  mailing_city                 :text(40)      not null
#  mailing_state                :text(20)      not null
#  mailing_postal_code          :text(20)      not null
#  mailing_country              :text(40)      not null
#  phone                        :string(40)    not null
#  fax                          :string(40)    not null
#  mobile_phone                 :string(40)    not null
#  home_phone                   :string(40)    not null
#  other_phone                  :string(40)    not null
#  reports_to_id                :text(18)      not null
#  email                        :string(80)    not null
#  title                        :text(80)      not null
#  department                   :text(80)      not null
#  lead_source                  :text(40)      not null
#  birthdate                    :date(0)       not null
#  description                  :text(32000)   not null
#  owner_id                     :text(18)      not null
#  has_opted_out_of_email       :boolean(0)    not null
#  do_not_call                  :boolean(0)    not null
#  created_date                 :datetime(0)   not null
#  created_by_id                :text(18)      not null
#  last_modified_date           :datetime(0)   not null
#  last_modified_by_id          :text(18)      not null
#  system_modstamp              :datetime(0)   not null
#  last_activity_date           :date(0)       not null
#  last_cu_request_date         :datetime(0)   not null
#  last_cu_update_date          :datetime(0)   not null
#  contact_full_name__c         :text(1300)    not null
#  onen_household_id__c         :text(18)      not null
#  marital_status__c            :text(255)     not null
#  household_links__c           :text(1300)    not null
#  volunteer_interests__c       :text(4099)    not null
#  deceased__c                  :boolean(0)    not null
#  map__c                       :text(1300)    not null
#  spouse_name__c               :text(80)      not null
#  addressee__c                 :text(200)     not null
#  contact_name_dashboard__c    :text(1300)    not null
#  philanthropic_interests__c   :text(4099)    not null
#  head_of_household__c         :boolean(0)    not null
#  certified__c                 :boolean(0)    not null
#  age__c                       :(0)           not null
#  do_not_mail__c               :boolean(0)    not null
#  member__c                    :boolean(0)    not null
#  past_member__c               :boolean(0)    not null
#  partner__c                   :boolean(0)    not null
#  twb_staff_member__c          :boolean(0)    not null
#  board_member__c              :boolean(0)    not null
#  volunteer__c                 :boolean(0)    not null
#  country_coordinator__c       :boolean(0)    not null
#  paid__c                      :boolean(0)    not null
#  if_so_rate_per_hour__c       :float(0)      not null
#  remote_id__c                 :text(20)      not null
#  remote_login__c              :text(60)      not null
#  employer__c                  :text(255)     not null
#  grade_level_experience__c    :text(4099)    not null
#  interest_areas__c            :text(4099)    not null
#  additional_skills__c         :text(32000)   not null
#  giraffe_heroes__c            :boolean(0)    not null
#  my_tec_c__c                  :boolean(0)    not null
#  twb_tools__c                 :boolean(0)    not null
#  newsletter__c                :boolean(0)    not null
#  why_joined__c                :text(32000)   not null
#  occupation__c                :text(255)     not null
#  first_language__c            :text(255)     not null
#  other_languages__c           :text(4099)    not null
#  employeeor_contractor__c     :text(255)     not null
#  professional_role__c         :text(255)     not null
#  intern_status__c             :text(255)     not null
#  volunteer_status__c          :text(255)     not null
#  assignment__c                :text(50)      not null
#  gender__c                    :text(255)     not null
#  age_group__c                 :text(255)     not null
#  education_level__c           :text(255)     not null
#  ctm_role__c                  :text(255)     not null
#  ctm_role_other__c            :text(32000)   not null
#  license__c                   :text(255)     not null
#  time_in_role__c              :text(255)     not null
#  ctm_reason__c                :text(255)     not null
#  ctm_goal__c                  :text(255)     not null
#  licensed_subject_areas__c    :text(32000)   not null
#  years_teaching_experience__c :text(255)     not null
#  twb_canada__c                :text(255)     not null
#  how_many_students__c         :text(255)     not null
#

# class for communicating with salesforce
class Contact < ActiveRecord::Base
    establish_connection :salesforce_production
    #include ActiveSalesforce::ActiveRecord::Mixin
    #set_table_name "contact"
end

# Salesforce Contact fields:
# last_name: "Guy", 
# first_name: "Test", 
# salutation: nil, 
# name: "Test Guy", 
# other_street: nil, 
# other_city: nil, 
# other_state: nil, 
# other_postal_code: nil, 
# other_country: nil, 
# mailing_street: nil, 
# mailing_city: nil, 
# mailing_state: nil, 
# mailing_postal_code: nil, 
# mailing_country: "US", 
# phone: nil, 
# fax: nil, 
# mobile_phone: nil, 
# home_phone: nil, 
# other_phone: nil, 
# reports_to_id: nil, 
# email: "testguy@example.com", 
# title: "The Main Tester (not a real user)", 
# department: nil, 
# lead_source: nil, 
# birthdate: nil, 
# description: nil, 
# owner_id: "003300000033d5jMMM", 
# has_opted_out_of_email: false, 
# do_not_call: false, 
# created_date: "2008-01-16 23:18:59", 
# created_by_id: "003300000033d5jMMM", 
# last_modified_date: "2008-07-03 00:05:46", 
# last_modified_by_id: "003300000033d5jMMM", 
# system_modstamp: "2008-07-03 00:05:46", 
# last_activity_date: "2008-01-16", 
# last_cu_request_date: nil, 
# last_cu_update_date: nil, 

# TWB specific
# contact_full_name__c: "<a href=\"/0044000000GGggG\" target=\"_blank\">Guy, Te...", 
# onen_household_id__c: "s0220000002BB3bBBB", 
# marital_status__c: nil, 
# household_links__c: "<a href=\"/servlet/servlet.Integration?lid=07M900000...", 
# volunteer_interests__c: nil, 
# deceased__c: false, 
# map__c: "<a href=\"/servlet/servlet.Integration?lid=00a900000...", 
# spouse_name__c: nil, 
# addressee__c: nil, 
# contact_name_dashboard__c: "Guy, Test", 
# philanthropic_interests__c: nil, 
# head_of_household__c: false, 
# certified__c: false, 
# age__c: nil, 
# do_not_mail__c: false, 
# member__c: false, 
# past_member__c: false, 
# partner__c: false, 
# twb_staff_member__c: true, 
# board_member__c: false, 
# volunteer__c: false, 
# country_coordinator__c: false, 
# paid__c: false, 
# if_so_rate_per_hour__c: nil, 
# wordpress_id__c: "1", 
# wordpress_login__c: "jbasdf", 
# employer__c: nil, 
# grade_level_experience__c: nil, 
# interest_areas__c: nil, 
# additional_skills__c: nil, 
# giraffe_heroes__c: false, 
# my_tec_c__c: false, 
# twb_tools__c: false, 
# twb_canada__c: false, 
# newsletter__c: false, 
# why_joined__c: nil, 
# occupation__c: nil, 
# first_language__c: nil, 
# other_languages__c: nil
