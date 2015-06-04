# `news_file`

From the [News File website](http://www.newsfilecorp.com/):

> Trusted since 1997, Newsfile simplifies compliance for public companies and investment managers. 

This isn't an official client. It parses links and articles, and is dead simple (<90 SLOC).

### How To

You need the company unique id. Epcylon is `3174`.

```ruby
company = NewsFile::Company.new('3174')
```

You can page through links.

```ruby
company.links.take(12)
``

You can page through articles.

```ruby
company.articles.each do |article|
  Article.create(article.to_h)
end
```

### Install

```ruby
# Gemfile

gem 'news_file', github: 'aj0strow/news_file', tag: 'v0.0.1'
```

```
$ bundle install
```

**MIT License**
