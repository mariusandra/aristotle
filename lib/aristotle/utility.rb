module Aristotle
  class Utility
    def self.check_all
      Dir[%w(app logic *.rb).join(File::SEPARATOR)].each do |file|
        require Dir.pwd + File::SEPARATOR + file
      end

      Aristotle::Logic.descendants.each_with_index do |logic_class, i|
        puts "Checking #{logic_class}"
        logic_class.is_everything_covered?
        puts if i > 0
      end
    end
  end
end
