module Aristotle
  class Logic
    def initialize(object)
      @object = object
    end

    def self.condition(expression, &block)
      @@conditions ||= {}
      @@conditions[expression.source] = block
    end

    def self.action(expression, &block)
      @@actions ||= {}
      @@actions[expression.source] = block
    end

    def self.load_commands
      @@commands ||= {}

      return if @@commands != {}

      #{Rails.root}/
      filename = "app/logic/#{logic_name}.logic"
      logic_data = File.read(filename)

      found_lines = []
      command = ''

      lines = logic_data.split("\n").map(&:rstrip).select { |l| l != '' }
      lines.each do |line|
        next if line.strip.start_with? '#'

        if !line.start_with?('  ')
          if command != '' && found_lines.length > 0
            @@commands[command] = found_lines
            found_lines = []
          end
          command = line
        elsif line.start_with?('  ')
          found_lines << line.strip
        end
      end
      @@commands[command] = found_lines if command != '' && found_lines.length > 0
    end

    def self.html_rules
      load_commands
      @@commands.map do |command, lines|
        "<strong>#{command}</strong><ul>#{lines.map{|l| "<li>- #{l.gsub(' if ', ' <strong style="color:blue">IF</strong> ').gsub(/'([^']+)'/, '<strong>\1</strong>')}</li>"}.join}</ul>"
      end.join('<br>').html_safe
    end

    def process_condition(condition)
      if @@conditions.has_key? condition
        @@conditions[condition].call(@object)
      else
        raise "Condition not found: #{condition}"
      end
    end

    def do_action(action)
      if @@actions.has_key? action
        @@actions[action].call(@object)
      else
        raise "Action not found: #{action}"
      end
    end

    def commands(logic_method)
      self.class.load_commands
      @@commands[logic_method] || []
    end

    def process(logic_method)
      commands(logic_method).each do |command|
        action, condition = command.split(' if ', 2)

        if process_condition(condition)
          # puts "Condition matched: #{condition}"
          # puts "Doing action: #{action}"
          return do_action(action)
        end
      end

      nil
    end

    def self.is_everything_covered?
      load_commands
      not_covered = {}
      @@commands.each do |logic_method, command|
        command.each do |line|
          action, condition = line.split(' if ', 2)

          unless @@actions.has_key?(action)
            not_covered[logic_method] ||= {actions: [], conditions: []}
            not_covered[logic_method][:actions] << action
          end
          unless @@conditions.has_key?(condition)
            not_covered[logic_method] ||= {actions: [], conditions: []}
            not_covered[logic_method][:conditions] << condition
          end
        end
      end

      if not_covered != {}
        not_covered.each do |request_method, data|
          puts "\nclass #{self.to_s} < Aristotle::Logic"
          puts "  # #{request_method}:\n"
          data[:actions].each do |action|
            puts "  action /#{action}/ do |#{logic_name}|\n\n  end\n\n"
          end
          data[:conditions].each do |condition|
            puts "  condition /#{condition}/ do |#{logic_name}|\n\n  end\n\n"
          end
          puts "end"
        end
      else
        puts '-> Everything is covered!'
      end

      not_covered == {}
    end

    protected

    def self.logic_name
      self.to_s.gsub(/Logic$/, '').gsub(/([a-z])([A-Z])/, '\1_\2').downcase
    end
  end
end
