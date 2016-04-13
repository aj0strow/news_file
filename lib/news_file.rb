require 'open-uri'
require 'nokogiri'
require 'date'

module NewsFile
  BASE_URL = 'http://www.newsfilecorp.com'

  # Allow structs to be created with hash instead of positional arguments.
  # For ex:
  #
  #     Point = HashStruct.new(:x, :y)
  #     point = Point.new(x: 5, y: 10)
  class HashStruct < Struct
    def self.new(*args)
      @@attributes = args.select { |arg| arg.is_a?(Symbol) }
      super
    end

    def initialize(attributes, *)
      if attributes.is_a? Hash
        values = attributes.values_at *@@attributes
        super *values
      else
        super
      end
    end
  end

  class Article < HashStruct.new(:id, :url, :title, :date, :location, :html)
    def self.fetch_and_parse(url)
      # allow relative urls
      url = "#{ BASE_URL }#{ url }" if url.start_with?('/')
      doc = Nokogiri::HTML(open(url))
      content = doc.css('.NewsReleaseDetailsContent')
      
      headings = %w(h1 h2 h3).map do |selector|
        content.css(selector).text
      end
      title = headings.find{ |text| !text.empty? }
      
      # replace old tags with modern equiv
      content.css('b').each { |b| b.name = 'strong' }
      paragraphs = content.css('p')[1..-1]
      id = url[ /release\/(\d+)/, 1 ]
      date = paragraphs.first.text[ /[[:alpha:]]+\s\d{1,2},\s\d{4}/, 0 ]
      location = paragraphs.first.text[ /\A[^-]+/, 0 ]
      html = paragraphs.map(&:to_s).join('')
      new(
        id: id,
        url: url,
        title: title,
        date: Date.parse(date),
        location: location,
        html: html.encode!('UTF-8')
      )
    end
  end

  class Company
    attr_reader :id, :requests

    def initialize(id)
      @id = id
      @requests = 0
    end

    def articles
      links_enum = links
      Enumerator.new do |enum|
        loop do
          article = Article.fetch_and_parse(links_enum.next)
          @requests += 1
          enum.yield article
        end
      end
    end

    def links
      page = 1
      Enumerator.new do |enum|
        loop do
          links = fetch_and_parse_links(page: page)
          @requests += 1
          links.each { |link| enum.yield link }
          raise StopIteration if links.length < 10
          page += 1
        end
      end
    end

    def fetch_and_parse_links(page: 1)
      url = "#{ BASE_URL }/company/#{ id }?pg=#{ page }"
      doc =  Nokogiri::HTML(open(url))
      links = doc.css('.content a').map { |a| a['href'] }
      links.select { |link| link.start_with?('/release') }
    end
  end
end
