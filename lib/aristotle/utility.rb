module Aristotle
  class Utility
    def self.check_all
      logic_objects.each_with_index do |logic_class, i|
        puts "Checking #{logic_class}"
        is_everything_covered_for? logic_class
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

    def self.is_everything_covered_for?(logic_class)
      not_covered = {}
      logic_class.commands.each do |logic_method, commands|
        commands.each do |command|
          unless command.has_action?
            not_covered[logic_method] ||= {actions: [], conditions: []}
            not_covered[logic_method][:actions] << command.action
          end
          unless command.has_condition?
            not_covered[logic_method] ||= {actions: [], conditions: []}
            not_covered[logic_method][:conditions] << command.condition
          end
        end
      end

      if not_covered != {}
        not_covered.each do |request_method, data|
          puts "\nclass #{self.to_s} < Aristotle::Logic"
          puts "  # #{request_method}:\n"
          data[:actions].each do |action|
            puts "  action /#{action}/ do |#{logic_class.logic_name}|\n\n  end\n\n"
          end
          data[:conditions].each do |condition|
            puts "  condition /#{condition}/ do |#{logic_class.logic_name}|\n\n  end\n\n"
          end
          puts "end"
        end
      else
        puts '-> Everything is covered!'
      end

      not_covered == {}
    end


  end
end
