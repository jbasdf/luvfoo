# == Schema Information
# Schema version: 20090123074335
#
# Table name: bag_properties
#
#  id                    :integer(4)    not null, primary key
#  bag_id                :integer(4)    default(1)
#  name                  :string(255)   
#  label                 :string(255)   
#  data_type             :integer(4)    default(1)
#  display_type          :string(255)   default("text")
#  required              :boolean(1)    
#  default_value         :string(255)   
#  default_visibility    :integer(4)    default(4)
#  can_change_visibility :boolean(1)    default(TRUE)
#  sort                  :integer(4)    default(9999)
#  width                 :integer(4)    default(-1)
#  height                :integer(4)    default(-1)
#  registration_page     :integer(4)    
#  sf_field              :string(255)   
#  is_link               :boolean(1)    
#  prefix                :string(255)   
#  maxlength             :integer(4)    default(5000)
#

class BagProperty < ActiveRecord::Base
  DATA_TYPE_STRING        = 1  
  DATA_TYPE_TEXT          = 2  
  DATA_TYPE_INTEGER       = 3  
  DATA_TYPE_TIMESTAMP     = 4  
  DATA_TYPE_ENUM          = 5
  
  DISPLAY_TYPE_TEXT           = 'text'
  DISPLAY_TYPE_CHECKBOX       = 'checkbox'
  DISPLAY_TYPE_RADIO          = 'radio'
  DISPLAY_TYPE_LIST           = 'list'
  DISPLAY_TYPE_DROP_DOWN_LIST = 'drop_down_list'
  DISPLAY_TYPE_CHECK_BOX_LIST = 'checkbox_list'
  DISPLAY_TYPE_TEXT_AREA      = 'textarea'
  DISPLAY_TYPE_OPTION         = 'option'
  
  VISIBILITY_ADMIN            = 1
  VISIBILITY_FRIENDS          = 2
  VISIBILITY_GROUPS           = 3
  VISIBILITY_USERS            = 4
  VISIBILITY_EVERYONE         = 5
  
  def enums user_id, property_id
    if user_id == nil
      BagPropertyEnum.find_by_sql(
        "SELECT *, id AS value " +
        "FROM bag_property_enums " + 
        "WHERE bag_property_enums.bag_property_id = #{property_id} " +
        "ORDER by sort, name")
    else
      BagPropertyEnum.find_by_sql(
        "SELECT *, bag_property_enums.id AS value, bag_property_values.bag_property_enum_id = bag_property_enums.id AS checked " +
        "FROM bag_property_enums " + 
        "LEFT OUTER JOIN bag_property_values on bag_property_enums.id = bag_property_values.bag_property_enum_id " +
        "AND bag_property_values.user_id = #{user_id} " +
        "WHERE bag_property_enums.bag_property_id = #{property_id} " +
        "ORDER by sort, name")
     end
  end
  
  def value
    case data_type
      when BagProperty::DATA_TYPE_STRING: return svalue       
      when BagProperty::DATA_TYPE_TEXT: return tvalue       
      when BagProperty::DATA_TYPE_INTEGER: return ivalue       
      when BagProperty::DATA_TYPE_TIMESTAMP: return tsvalue       
      when BagProperty::DATA_TYPE_ENUM: return enum_list if bag_property_enum_id != '-1' && bag_property_enum_id != nil
      else return nil
    end
  end
  
  protected
  
  def enum_list
    list = BagPropertyEnum.find_by_sql(
        "SELECT name " +
        "FROM bag_property_enums " + 
        "INNER JOIN bag_property_values on bag_property_enums.id = bag_property_values.bag_property_enum_id " +
        "WHERE bag_property_enums.bag_property_id = #{bag_property_id} " +
        "AND bag_property_values.user_id = #{user_id} " +
        "ORDER by sort, name")

    list.collect{|e| e.name}.join(', ')
  end
  
end
