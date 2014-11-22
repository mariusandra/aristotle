module Aristotle
  class Presenter
    def initialize(klass)
      @klass = klass
    end

    def html_rules(show_code: true)
      @klass.commands.map do |command_title, commands|
        "<strong>#{command_title}</strong>"+
            "<ul>"+
            commands.map do |command|
              "<li>- "+
                  format_fragment(command, :action, show_code: show_code)+
                  " <strong style='color:blue'>IF</strong> "+
                  format_fragment(command, :condition, show_code: show_code)+
                  "</li>"
            end.join +
            "</ul>"
      end.join('<br>').html_safe
    end

    protected

    def format_fragment(fragment, part, show_code: true)
      return '' if part != :action && part != :condition

      text = fragment.send(part).to_s
      text.gsub!(/'([^']+)'/, '<strong>\1</strong>')

      proc = fragment.send("#{part}_proc")

      return "<span style='color:red'>#{text}</span>" if proc.blank?
      return text unless show_code

      code = find_code(*proc.source_location) || 'no code found'

      code_block = "<span style='color:#aaaaaa;'>#{proc.source_location.join(':')}</span>\n"+
          "<span style='color:#333333'>#{code.join("\n")}</span>"

      "<span style='position:relative;cursor:help;' onmouseover='this.children[0].style.display=\"block\";' onmouseout='this.children[0].style.display=\"none\";'>"+
          "<pre style='position:absolute;cursor:text;display:none;background:#ffffff;margin-top:0;padding:6px 8px;box-shadow:2px 2px 8px rgba(0,0,0,0.3);z-index:30000;'>"+
              "#{code_block}"+
          "</pre>"+
          "#{text}"+
      "</span>"
    end

    def find_code(file, line_number)
      lines = load_file(file)
      first_line = lines[line_number - 1]
      indention = first_line.index(/[^ ]/)

      code_lines = lines[(line_number - 1)..-1]
      end_regexp = Regexp.new('^' + (' ' * indention) + 'end *')
      to = code_lines.find_index { |line| line =~ end_regexp } + 1

      code_lines.first(to).map { |line| line[indention..-1] }
    rescue
      nil
    end

    def load_file(file)
      @files ||= {}
      @files[file] ||= open(file).read.split("\n").map(&:rstrip)
    end
  end
end
