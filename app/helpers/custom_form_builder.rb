class CustomFormBuilder < ActionView::Helpers::FormBuilder

  helpers = field_helpers +
  %w(date_select datetime_select time_select collection_select) +
  %w(select country_select time_zone_select) -
  %w(hidden_field label fields_for)

  helpers.each do |name|
    define_method name do |field, *args|
      options = args.detect {|argument| argument.is_a?(Hash)} || {}

      render_field_template(name, field, options) do
        super
      end
    end
  end

  def render_field_template(name, field, options)

    tippable = !options[:tip].nil?

    local_options = {
      :extra_html => options.delete(:extra_html),
      :tip        => options.delete(:tip),
      :wrapper_id => options.delete(:wrapper_id),
      :pre_html   => options.delete(:pre_html),
      :hide_required => options.delete(:hide_required)
    }

    type = options.delete(:type)
    type ||= :tippable if tippable

    if !options[:label_class].nil?
      label_options = { :class => options.delete(:label_class) }
    else
      label_options = { }
    end


    if local_options[:hide_required]
      required = false
      label_text = options[:label]
    else
      required = required_field?(field)
      label_text = (options[:label] || field.to_s.camelize)
      label_text = label_text + required_mark(field)
    end
    label_name = options.delete(:label)

    is_checkbox = false
    is_checkbox = true if %w(check_box).include?(name)

    options[:class] ||= ''
    options[:class] << add_space_to_css(options) + 'tip-field' if tippable
    options[:class] << add_space_to_css(options) + "required-value" if required_field?(field)

    if type == :choose_menu
      options[:label_class] = 'desc'
    end

    locals = {
      :field_element  => yield,
      :field_name     => field_name(field),
      :label_name     => options.delete(:required_label) || label_name || '',
      :label_element  => label(field, label_text, label_options),
      :is_checkbox    => is_checkbox,
      :required       => required
    }.merge(local_options)

    if object.nil?
      locals[:value] = ''
      locals[:id] = ''      
    else
      locals[:value] = object.send(field)
      locals[:id] = object.id
    end

    if has_errors_on?(field)
      locals.merge!(:error => error_message(field, options))
    end

    @template.capture do

      if type == :tippable              
        @template.render :partial => 'forms/field_with_tips', :locals => locals
      elsif type == :choose_menu
        @template.render :partial => 'forms/menu_field', :locals => locals
      elsif type == :color_picker
        @template.render :partial => 'forms/color_picker_field', :locals => locals
      elsif type == :default  
        @template.render :partial => 'forms/default', :locals => locals
      else
        @template.render :partial => 'forms/field', :locals => locals
      end
    end
  end

  def state_select(method, options = {}, html_options = {})
    @states ||= State.find(:all, :order => 'name asc')
    self.menu_select(method, 'Choose State', @states, options.merge(:prompt => 'Please select a state', :wrapper_id => 'states-container'), html_options.merge(:id => 'states'))
  end

  def country_select(method, options = {}, html_options = {})
    @countries = []
    self.menu_select(method, 'Choose Country', @counties, options.merge(:prompt => 'Please select a country', :wrapper_id => 'countries-container'), html_options.merge(:id => 'countries'))
  end

  def lookup_type_select(method, options = {}, html_options = {})
    @lookup_types = LookupType.find(:all, :order => 'name asc')
    self.menu_select(method, 'Choose Lookup Type', @lookup_types, options.merge(:prompt => 'Please select a lookup type', :wrapper_id => 'lookup-types-container'), html_options.merge(:id => 'lookup-types'))
  end

  def menu_select(method, label, collection, options = {}, html_options = {})
    self.collection_select(method, collection, :id, :name, options.merge(:object => @object, :label => label, :type => :choose_menu, :label_class => 'desc'), html_options)
  end

  private

  def add_space_to_css(options)
    options[:class].empty? ? '' : ' '
  end

  def error_message(field, options)
    if has_errors_on?(field)
      errors = object.errors.on(field)
      errors.is_a?(Array) ? errors.to_sentence : errors
    else
      ''
    end
  end

  def has_errors_on?(field)
    !(object.nil? || object.errors.on(field).blank?)
  end

  def field_name(field)
    # TODO figure out if there is a built in method that does this.
    "#{@object_name.to_s}_#{field.to_s}"
  end

  def required_mark(field)
    required_field?(field) ? " <em id=\"#{field_name(field)}-label-required\">(required)</em>" : ''
  end

  def required_field?(field)
    @object_name.to_s.camelize.constantize.
    reflect_on_validations_for(field).
    map(&:macro).include?(:validates_presence_of)
  end

end
