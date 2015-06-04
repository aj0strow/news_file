Gem::Specification.new do |s|
  s.name = 'news_file'
  s.version = '0.0.1'
  s.license = 'MIT'
  
  s.homepage = 'https://github.com/aj0strow/news_file'
  s.date = '2015-06-04'
  s.summary = 'newsfilecorp.com scraper'
  s.description = 'scrape links and artciles from news file'
  s.authors = %w(aj0strow)
  s.email = 'alexander.ostrow@gmail.com'
  
  s.add_runtime_dependency 'nokogiri', '~> 1.6'
  
  s.files = `git ls-files`.split(/\n/)
  s.test_files = `git ls-files -- test`.split(/\n/)
end
