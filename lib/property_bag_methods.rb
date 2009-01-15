module PropertyBagMethods
  
    def properties_for_page page_number
      @properties_for_page = BagProperty.find_by_sql(
        ['SELECT *, bag_properties.required, bag_property_values.svalue, bag_property_values.tvalue, bag_property_values.ivalue, ' +
        'COALESCE(bag_property_values.visibility, bag_properties.default_visibility) AS visibility, bag_properties.data_type, ' +
        'bag_properties.id AS bag_property_id ' +
        'FROM bag_properties ' +
        'LEFT OUTER JOIN bag_property_values ON bag_properties.id = bag_property_values.bag_property_id AND user_id = ? ' +
        'WHERE bag_properties.registration_page = ? ' +
        'GROUP BY bag_properties.id ' +
        'ORDER BY sort, bag_properties.id', self.id, page_number]) if @properties_for_page == nil
      return @properties_for_page
    end

    def update_from_params params
      BagPropertyValue.transaction do
        update_property_bag params[:property], params[:v], params[:dt] if params[:property] != nil 
        @property_bag = nil
        update_attributes(params[:user])
        if self.errors.count > 0
          raise ActiveRecord::Rollback.new
        else
          create_feed_item 'updated_profile'
          return true
        end  
      end
    end

    def update_property_bag bag_values, visibilities, data_types
      BagPropertyValue.delete_all(:user_id => self.id)
      bag_values.each do |key, value|
        if value.is_a?(Array)
          value.each do |avalue|
            update_property_bag_value data_types[key].to_i, key, avalue, visibilities[key].to_i
          end
        else
          update_property_bag_value data_types[key].to_i, key, value, visibilities[key].to_i
        end
      end
    end

    def property_value name
      p = property(name)
      p.nil? ? nil : p.value
    end

    def property name
      build_property_bag if @property_bag.nil?
      @property_bag[name]
    end

    def visibility_threshold viewer
      if viewer == :false
        return BagProperty::VISIBILITY_EVERYONE
      elsif viewer.is_admin? || viewer.id == self.id
        return BagProperty::VISIBILITY_ADMIN
      elsif viewer.friend_of?(self)
        return BagProperty::VISIBILITY_FRIENDS
      else
        return BagProperty::VISIBILITY_USERS
      end
    end

    def visible_properties viewer
      properties_visible_to visibility_threshold(viewer)
    end

    protected

    def properties_visible_to threshold
      BagProperty.find_by_sql(
        ['SELECT *, bag_property_values.user_id, ' +
        'bag_properties.data_type, ' +
        'bag_properties.id AS bag_property_id ' +
        'FROM bag_properties ' +
        'INNER JOIN bag_property_values ON bag_properties.id = bag_property_values.bag_property_id AND user_id = ? AND bag_properties.display_type != \'option\' ' +
        'WHERE bag_property_values.visibility >= ? ' +
        'GROUP BY bag_properties.id ' +
        'ORDER BY sort, bag_properties.id', self.id, threshold])
    end

    def validate
      other_selected = false
      hidden = true
      previous_property = nil
      BagProperty.find(:all, :conditions => 'required = true', :order => 'sort ASC').each do |p|
  #    puts "validating: #{p.name}=#{property_value(p.name)}"
        if p.name =~ /_other$/ && property_value(p.name) == nil
          if previous_property != nil && previous_property.data_type == BagProperty::DATA_TYPE_ENUM
            enums = previous_property.enums(self.id, previous_property.id)
            other_value = (enums.last.sort == 9999 ? enums.last.name : -2)  
            hidden = (property_value(previous_property.name) != other_value)
          end
          errors.add p.label, " can't be blank." if property_value(p.name) == nil && !hidden
        else
          errors.add p.label, " can't be blank." if property_value(p.name) == nil
        end
        previous_property = p
      end
    end

    def build_property_bag
      @property_bag = Hash.new
      properties.each do |p|
        @property_bag[p.name] = p
      end
    end

    def update_property_bag_value pdata_type, pid, pvalue, pvisibility
      return if pvalue == nil || pvalue == '' 
      case pdata_type
        when BagProperty::DATA_TYPE_STRING: BagPropertyValue.create(:bag_property_id => pid, :user_id => self.id, :svalue => pvalue, :visibility => pvisibility)       
        when BagProperty::DATA_TYPE_TEXT: BagPropertyValue.create(:bag_property_id => pid, :user_id => self.id, :tvalue => pvalue, :visibility => pvisibility)       
        when BagProperty::DATA_TYPE_INTEGER: BagPropertyValue.create(:bag_property_id => pid, :user_id => self.id, :ivalue => pvalue, :visibility => pvisibility)       
        when BagProperty::DATA_TYPE_TIMESTAMP: BagPropertyValue.create(:bag_property_id => pid, :user_id => self.id, :tsvalue => pvalue, :visibility => pvisibility)       
        when BagProperty::DATA_TYPE_ENUM: BagPropertyValue.create(:bag_property_id => pid, :user_id => self.id, :bag_property_enum_id => pvalue, :visibility => pvisibility)       
      end
    end
    
end