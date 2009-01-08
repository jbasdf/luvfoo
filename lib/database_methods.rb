module DatabaseMethods
   
    # this does not protect against sql injection and is only intended
    # for internal use
    def self.get_conditions(key, conditions)
      conditions.collect {|c| "#{key} LIKE '#{c}'"}.join(" OR ")
    end
   
end
