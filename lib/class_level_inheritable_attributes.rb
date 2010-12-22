module ClassLevelInheritableAttributes
  def self.included(base)
    base.extend(ClassMethods)    
  end
  
  module ClassMethods
    def class_inheritable_attributes(*args)
      @xeroizer_inheritable_attributes ||= [:inheritable_attributes]
      @xeroizer_inheritable_attributes += args
      args.each do |arg|
        class_eval %(
          class << self; attr_accessor :#{arg} end
        )
      end
      @xeroizer_inheritable_attributes
    end
    
    def inherited(subclass)
      @xeroizer_inheritable_attributes.each do |inheritable_attribute|
        instance_var = "@#{inheritable_attribute}"
        subclass.instance_variable_set(instance_var, instance_variable_get(instance_var))
      end
    end
  end
end