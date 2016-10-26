Gem::Specification.new do |s|

  s.authors = ["Mickael Riga"]
  s.email = ["mig@mypeplum.com"]
  s.homepage = "https://github.com/mig-hub/key-value-parser"
  s.licenses = ['MIT']

  s.name = 'key-value-parser'
  s.version = '0.0.2'
  s.summary = "Key Value Parser"
  s.description = "KeyValueParser parses arrays of string options like 'machine=coconut'. It is mainly done for parsing ARGV, but can be used for other things."

  s.platform = Gem::Platform::RUBY
  s.files = `git ls-files`.split("\n").sort
  s.test_files = s.files.grep(/^test\//)
  s.require_paths = ['lib']

end

