module Aristotle
  class Presenter
    def initialize(klass)
      @klass = klass
    end

    def html_rules
      @klass.commands.map do |command, lines|
        "<strong>#{command}</strong>"+
            "<ul>"+
            lines.map do |line|
              "<li>- "+
                  line.action.gsub(/'([^']+)'/, '<strong>\1</strong>')+
                  " <strong style='color:blue'>IF</strong> "+
                  line.condition.gsub(/'([^']+)'/, '<strong>\1</strong>')+
                  "</li>"
            end.join +
            "</ul>"
      end.join('<br>').html_safe
    end
  end
end
