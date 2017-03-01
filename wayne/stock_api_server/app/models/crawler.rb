class Crawler
  require 'nokogiri'
  require 'open-uri'

  DATA_COUNT = 50
  TURNOVER_URI = 'http://stock.wearn.com/qua.asp'.freeze
  PRICE_UP_COLOR = '#ec008c'.freeze
  PRICE_DOWN_COLOR = '#009900'.freeze

  def self.crawl_daily_data
    doc = html_parse
    node = doc.css('div.stockalllist > table tr[class^="stockalllistbg"]')

    turnovers = node.map do |tr|
      stock = tr.css('> td')
      # get the company link
      href = stock[2].css('> a')[0]['href']
      # get change number
      font = stock[9].css('> table tr > td:nth-child(2) > font')
      change =
        if font.empty?
          0
        else
          get_change_by_color(font[0].content.to_f, font[0]['color'])
        end
      get_stock_obj(stock, href, change)
    end
    puts turnovers.first(DATA_COUNT)
  end

  # Fetch and parse HTML document
  def self.html_parse
    html = open(TURNOVER_URI).read
    charset = 'big5'
    html.force_encoding(charset)
    html.encode!('utf-8', undef: :replace, replace: '?', invalid: :replace)
    Nokogiri.parse(html)
  end

  def self.get_stock_obj(node, href, change)
    {
      stock_number: node[1].content.strip,
      stock_name: node[2].content.strip,
      stock_company_url: href.strip,
      stock_opening_price: node[3].content.strip.to_f,
      stock_highest_price: node[4].content.strip.to_f,
      stock_floor_price: node[5].content.strip.to_f,
      stock_closing_yesterday: node[6].content.strip.to_f,
      stock_closing_today: node[7].content.strip.to_f,
      stock_volumn: node[8].content.strip.tr(',', '').to_i,
      stock_change: change,
      stock_quote_change: node[10].content.partition('%').first.to_f
    }
  end

  # get change number by specific color
  def self.get_change_by_color(number, color)
    if color == PRICE_UP_COLOR
      number
    elsif color == PRICE_DOWN_COLOR
      -number
    end
  end
  private_class_method :html_parse, :get_stock_obj, :get_change_by_color
end
