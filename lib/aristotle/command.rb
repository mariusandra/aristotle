module Aristotle
  class Command
    attr_reader :action, :condition, :action_proc, :condition_proc

    def initialize(line, conditions, actions)
      @action, @condition = line.split(' if ', 2).map(&:strip)

      raise 'Badly formatted line' if @action == '' || @condition == ''

      conditions.each do |condition_regexp, condition_proc|
        match_data = condition_regexp.match(@condition)
        if match_data
          @condition_proc = condition_proc
          @condition_attributes = match_data.to_a[1..-1]
        end
      end

      actions.each do |action_regexp, action_proc|
        match_data = action_regexp.match(@action)
        if match_data
          @action_proc = action_proc
          @action_attributes = match_data.to_a[1..-1]
        end
      end
    end

    def do_action_with(object)
      if @action_proc
        @action_proc.call(object, *@action_attributes)
      else
        raise "Action not found: #{@action}"
      end
    end

    def condition_passes_with?(object)
      if @condition_proc
        @condition_proc.call(object, *@condition_attributes)
      else
        raise "Condition not found: #{@condition}"
      end
    end

    def has_action?
      !@action_proc.nil?
    end

    def has_condition?
      !@condition_proc.nil?
    end
  end
end
