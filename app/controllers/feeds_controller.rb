require 'rss'
require 'open-uri'

class FeedsController < ApplicationController
  def index
    navercast_atom_feed_url = 'https://navercast.petabytes.org'.freeze
    benjaminlog_rss_url = 'http://feeds.feedburner.com/crazytazo?format=xml'.freeze
    minjang_rss_url = 'http://rss.egloos.com/blog/minjang'.freeze

    feed_urls = [navercast_atom_feed_url, benjaminlog_rss_url, minjang_rss_url]

    rss = RSS::Maker.make('atom') do |maker|
      maker.channel.author = 'Benjamin'
      maker.channel.about = '피드 통합 테스트'
      maker.channel.title = '온동네 개발자 피드 모음'

      feed_urls.each do |url|
        feed = Feedjira::Feed.fetch_and_parse(url)

        feed.entries.each do |entry|
          maker.items.new_item do |item|
            item.link = entry.url.tap { |x| puts x }
            item.title = entry.title.tap { |x| puts x }
            item.updated = entry.published.tap { |x| puts x }
            item.summary = entry.summary.tap { |x| puts x }
          end
        end
      end
      maker.channel.updated = maker.items.max_by { |x| x.updated.to_i }.updated
    end

    render xml: rss.to_xml
  end
end