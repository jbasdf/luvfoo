class Test::Unit::TestCase

  def self.should_act_as_taggable_on_steroids
    klass = self.name.gsub(/Test$/, '').constantize

    should "include ActsAsTaggableOnSteroids methods" do
      assert klass.extended_by.include?(ActiveRecord::Acts::Taggable::ClassMethods)
      assert klass.extended_by.include?(ActiveRecord::Acts::Taggable::SingletonMethods)
      assert klass.include?(ActiveRecord::Acts::Taggable::InstanceMethods)
    end

    should_have_many :taggings, :tags
  end


  def self.should_act_as_list
    klass = self.name.gsub(/Test$/, '').constantize

    context "To support acts_as_list" do
      should_have_db_column('position', :type => :integer)
    end

    should "include ActsAsList methods" do
      assert klass.include?(ActiveRecord::Acts::List::InstanceMethods)
    end

    should_have_instance_methods :acts_as_list_class, :position_column, :scope_condition
  end

end