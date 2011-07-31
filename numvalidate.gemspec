Gem::Specification.new do |s|
  s.name    = 'numvalidate'
  s.version = '0.0.1'
  s.summary = 'RSpec matchers for ensuring that numeric validation happens in your models.'

  s.author   = 'Larry Glenn'
  s.email    = 'larry@evilworldheadquerters.org'
  s.homepage = 'https://github.com/lglenn/numvalidate'

  # These dependencies are only for people who work on this gem
  s.add_development_dependency 'rspec'

  # Include everything in the lib folder
  s.files = Dir['lib/**/*']

  # Supress the warning about no rubyforge project
  s.rubyforge_project = 'nowarning'
end
