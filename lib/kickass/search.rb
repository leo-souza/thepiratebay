require 'nokogiri'
require 'open-uri'
require 'uri'

module Kickass
  class Search
    attr_reader :torrents
    alias_method :results, :torrents

    def initialize(query, page = 0, sort_by = 99, category = 0)

      query = URI.escape(query)
      doc = Nokogiri::HTML(open("http://kickass.to/usearch/#{query}/?field=seeders&sorder=desc"))
      torrents = []

      doc.css('table.data:not(.font12px)').first.css('tr').each do |row|
        title = row.search('.cellMainLink').text
        next if title == ''

        seeders     = row.search('td')[4].text.to_i
        leechers    = row.search('td')[5].text.to_i
        magnet_link = row.search('.imagnet')[0]['href']
        category    = row.css('.torType span > span a')[0].text
        url         = row.search('.cellMainLink').attribute('href').to_s
        torrent_id  = url.match(/t(\d+)\.html$/)[1]

        torrent = {:title       => title,
                   :seeders     => seeders,
                   :leechers    => leechers,
                   :magnet_link => magnet_link,
                   :category    => category,
                   :torrent_id  => torrent_id,
                   :url         => url}

        torrents.push(torrent)
      end

      @torrents = torrents
    end
  end
end
