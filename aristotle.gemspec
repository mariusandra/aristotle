Gem::Specification.new do |s|
  s.name        = 'aristotle'
  s.version     = '0.2.4'
  s.date        = '2014-11-25'
  s.summary     = 'Business logic'
  s.description = 'Ruby business logic engine, inspired by Cucumber'
  s.authors     = ['Marius Andra']
  s.email       = 'marius@apprentus.com'
  s.files       = ['lib/aristotle.rb', 'lib/aristotle/command.rb', 'lib/aristotle/logic.rb', 'lib/aristotle/utility.rb', 'lib/aristotle/presenter.rb']
  s.test_files  = ['test/test_aristotle.rb', 'app/logic/test.logic']

  s.homepage    = 'https://github.com/apprentus/aristotle'
  s.license     = 'MIT'
  s.executables << 'aristotle'
end
