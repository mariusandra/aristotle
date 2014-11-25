module Aristotle
  class Utility
    def self.check_all
      logic_objects.each do |logic_object|
        puts "Checking #{logic_object[:class_name]}"
        is_everything_covered_for? logic_object
        puts
      end
    end

    protected

    def self.logic_objects
      init_logic_objects if @logic_objects.nil? || @logic_objects == {}

      @logic_objects
    end

    def self.init_logic_objects
      @logic_objects ||= []

      Dir[%w(app logic *.logic).join(File::SEPARATOR)].each do |file|
        logic_name = file.split(File::SEPARATOR).last.split('.logic').first
        folder = %W{#{Dir.pwd} app logic}.join(File::SEPARATOR)
        class_name = logic_name.split('_').map(&:capitalize).join('') + 'Logic'

        logic_object = {
            logic_file: folder + File::SEPARATOR + "#{logic_name}.logic",
            class_file: folder + File::SEPARATOR + "#{logic_name}_logic.rb",
            relative_class_file: %W(app logic #{logic_name}_logic.rb).join(File::SEPARATOR),
            class_name: class_name
        }

        begin
          require logic_object[:class_file]
          logic_object[:logic_class] = Object.const_get(class_name)
        rescue LoadError => e
          logic_object[:logic_class] = nil
        rescue
          logic_object[:logic_class] = nil
        end

        @logic_objects << logic_object
      end
    end

    def self.is_everything_covered_for?(logic_object)
      logic_class = logic_object[:logic_class]

      if logic_class.nil?
        puts "--> Create file #{logic_object[:relative_class_file]} with the following contents:"
        puts "class #{logic_object[:class_name]} < Aristotle::Logic"
        puts '  # ...'
        puts 'end'
        return
      end

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
          puts "\n# #{logic_object[:relative_class_file]}"
          puts "class #{logic_object[:class_name]} < Aristotle::Logic"
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
