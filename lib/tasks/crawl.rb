require 'open-uri'
require 'pry'

module Tasks
  class Crawl
    def self.do
      source_uri = 'https://raw.githubusercontent.com/sarojaba/awesome-devblog/master/README.md'
      lines = RestClient.get(source_uri).body.split("\n")

      lines.each do |line|
        m = line.match(/\* \[(?<author_name>.+?)\]\((?<url>.+?)\)(\(.*\))?( - (?<tag>.+))?/)

        if m && m[:author_name] && m[:url]
          puts "SUCCEED, NAME: #{m[:author_name]}, URL: #{m[:url]}, tag: #{m[:tag]}"
        else
          if line.start_with?('#') || line.blank?
          else
            puts "FAILED: #{line}"
          end
        end
      end
    end

    def self.openml
      doc = Nokogiri::XML(open('https://raw.githubusercontent.com/sarojaba/awesome-devblog/master/Korea-Dev-RSS.opml'))
      # puts doc.inspect
      feeds = []
      doc.xpath('//outline/outline').each do |link|
        h = {}
        h[:feed_url] = link.attr('xmlUrl')
        h[:author_name] = link.attr('title')
        h[:feed_type] = link.attr('type')
        feeds << h
      end

      puts feeds.to_yaml
    end
  end
end
