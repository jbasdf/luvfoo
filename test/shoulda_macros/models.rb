Test::Unit::TestCase.class_eval do

  def self.should_whitelist(*attributes)
    bad_scripts = [
      %|';alert(String.fromCharCode(88,83,83))//\';alert(String.fromCharCode(88,83,83))//";alert(String.fromCharCode(88,83,83))//\";alert(String.fromCharCode(88,83,83))//--></SCRIPT>">'><SCRIPT>alert(String.fromCharCode(88,83,83))</SCRIPT>|,
      %|'';!--"<XSS>=&{()}|,
      %|<SCRIPT SRC=http://ha.ckers.org/xss.js></SCRIPT>|,
      %|<IMG SRC="javascript:alert('XSS');">|,
      %|<IMG SRC=javascript:alert('XSS')>|,
      %|<IMG SRC=JaVaScRiPt:alert('XSS')>|,
      %|<IMG SRC=JaVaScRiPt:alert('XSS')>|,
      %|<IMG SRC=`javascript:alert("RSnake says, 'XSS'")`>|,
      %|<IMG """><SCRIPT>alert("XSS")</SCRIPT>">|,
      %|<IMG SRC=javascript:alert(String.fromCharCode(88,83,83))>|,
      %|<A HREF="h
      tt	p://6&#9;6.000146.0x7.147/">XSS</A>|,
      %|<script>alert('message');</script>| ]
      
    klass = model_class
    attributes.each do |attribute|
      attribute = attribute.to_sym
      should "white list #{attribute}" do
        assert object = klass.find(:first), "Can't find first #{klass}"
        bad_scripts.each do |bad_value|
          object.send("#{attribute}=", bad_value)
          object.save
          clean_value = object.send("#{attribute}")
          assert !clean_value.include?(bad_value), "#{attribute} is not white listed. #{bad_value} made it through"
        end
      end
    end
  end

end