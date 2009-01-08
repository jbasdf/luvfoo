require 'active_record'

module Expressica #:nodoc
  
  module ValidateAttributes
    
    module ModelHelpers #:nodoc
      
      def self.included(base)
        base.module_eval{@@skipping_attributes = false}
      end
      
      def validate_attributes(options={})
        validate_attributes?(get_validatable_attributes(options))
      end
      
      def validate_attributes_and_save(options={})
        if validate_attributes?(get_validatable_attributes(options))
          save(false)
        else
          false
        end
      end
      
      def validate_attributes?(attr=[]) #:nodoc
        attr = attr.flatten.collect{|el| el.to_s}
        return valid? if attr.empty?
        previous_errors = errors.instance_variable_get("@errors").clone
        if valid?
          return true
        else
          valid = true
          new_errors = errors.instance_variable_get("@errors")
          errors_to_delete = []
          unless @@skipping_attributes
            new_errors.each do |attr_name, attr_error|
              if attr.include?(attr_name)
                valid = false
                previous_errors.delete(attr_name)
              else
                errors_to_delete << attr_name
              end
            end
            previous_errors.delete_if{|attr_name, attr_error| attr.include?(attr_name) and !new_errors.keys.include?(attr_name)}
            remove_these_errors(errors_to_delete)
            errors.instance_variable_get("@errors").update(previous_errors)
          else
            remove_these_errors(attr)
            previous_errors.delete_if{|attr_name, attr_error| !attr.include?(attr_name)}
            errors.instance_variable_get("@errors").update(previous_errors)
            valid = false unless errors.instance_variable_get("@errors").empty?
          end
          GC.start
          return valid
        end
      end
      
      def remove_these_errors(errors_list=[]) #:nodoc
        current_errors = errors.instance_variable_get("@errors")
        errors_list.each{|attr_name| current_errors.delete(attr_name.to_s)}
      end
      
      def get_validatable_attributes(options={})
        @@skipping_attributes = false
        only, except = options[:only], options[:except]
        begin
          case [only.nil?, except.nil?]
          when [true, true], [false, false]
            return []
          when [false, true]
            return [only].flatten
          when [true, false]
            @@skipping_attributes = true
            return [except].flatten
          end
        rescue
          return []
        end
      end
      
      private :remove_these_errors, :get_validatable_attributes, :validate_attributes?
    end
  end
end

ActiveRecord::Base.module_eval do
  include Expressica::ValidateAttributes::ModelHelpers
end
