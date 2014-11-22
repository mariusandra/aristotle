module Aristotle
  class Utility
    def self.check_all
      logic_objects.each_with_index do |logic_class, i|
        puts "Checking #{logic_class}"
        logic_class.is_everything_covered?
        puts if i > 0
      end
    end

    protected

    def self.logic_objects
      init_logic_objects unless @logic_objects_initialized

      ObjectSpace.each_object(Class).select { |klass| klass < Aristotle::Logic }
    end

    def self.init_logic_objects
      Dir[%w(app logic *.rb).join(File::SEPARATOR)].each do |file|
        require Dir.pwd + File::SEPARATOR + file
      end
      @logic_objects_initialized = true
    end
  end
end
