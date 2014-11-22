module Aristotle
  class Command
    attr_reader :action, :condition

    def initialize(line, conditions, actions)
      # TODO: make this properly work with regexps
      @action, @condition = line.split(' if ', 2).map(&:strip)

      raise 'Badly formatted line' if @action == '' || @condition == ''

      @condition_proc = conditions[Regexp.new(@condition)]
      @action_proc = actions[Regexp.new(@action)]
    end

    def do_action_with(object)
      if @action_proc
        @action_proc.call(object)
      else
        raise "Action not found: #{@action}"
      end
    end

    def condition_passes_with?(object)
      if @condition_proc
        @condition_proc.call(object)
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
