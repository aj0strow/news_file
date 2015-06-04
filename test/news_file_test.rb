require 'news_file'
require 'minitest/autorun'
require 'uri'

class NewsFileTest < Minitest::Test
  def company
    @company ||= NewsFile::Company.new('3174')
  end

  def test_article
    article = NewsFile::Article.new(id: '123')
    assert_equal '123', article.id
  end

  def test_fetch_and_parse_links
    links = company.fetch_and_parse_links
    assert_equal 10, links.length
    refute links.any? { |link| String(link).empty? }
  end

  def test_iterate_links
    prev_requests = company.requests
    links = company.links.take(3)
    assert_equal 1, company.requests - prev_requests
    assert_equal 3, links.length
  end

  def test_article_fetch_and_parse
    article = NewsFile::Article.fetch_and_parse('/release/9712')    
    assert_equal '9712', article[:id]
    assert_match /^Epcylon/, article.title
    assert_equal Date.new(2014, 5, 1), article.date
    assert_equal 'Toronto, Ontario', article.location
  end

  def test_interate_articles
    prev_requests = company.requests
    articles = company.articles.take(1)
    assert_equal 2, company.requests - prev_requests
    assert_equal 1, articles.length
  end
end
