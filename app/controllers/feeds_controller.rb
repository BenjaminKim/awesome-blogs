require 'open-uri'
require 'addressable/uri'

class FeedsController < ApplicationController
  def index
    # x.scan(/xmlUrl=".*?"/).each {|x| puts x[7..-1] + ','}
    group = params[:group] || 'dev'

    if group == 'all'
      feeds = Rails.configuration.feeds.inject([]) do |array, e|
        array + e.second
      end
    else
      feeds = Rails.configuration.feeds[group]
    end

    now = Time.zone.now
    @rss = RSS::Maker.make('atom') do |maker|
      maker.channel.author = '어썸블로그'.freeze
      maker.channel.about = '국내의 좋은 블로그 글들을 매일 배달해줍니다.'.freeze
      maker.channel.title = channel_title(group)

      Parallel.each(feeds, in_threads: 30) do |feed_h|
        begin
          feed_url = feed_h[:feed_url]
          feed = Rails.cache.fetch(feed_url, expires_in: cache_expiring_time) do
            puts "cache missed: #{feed_url}"
            Timeout::timeout(3) {
              Feedjira::Feed.fetch_and_parse(feed_url)
            }
          end

          next if feed.nil?

          feed.entries.each do |entry|
            if entry.published < now - 15.days || entry.published.localtime > Time.now
              next
            end
            maker.items.new_item do |item|
              link_uri = entry.url || entry.entry_id
              Rails.logger.info("LINK: #{link_uri}") unless link_uri.start_with?('http')
              if link_uri.blank?
                Rails.logger.error("ERROR - url shouldn't be null: #{entry.inspect}")
              else
                begin
                  uri = Addressable::URI.parse(link_uri)
                  uri.host ||= Addressable::URI.parse(feed_url).host
                  uri.scheme ||= Addressable::URI.parse(feed_url).scheme
                  item.link = uri.to_s
                rescue Exception => e
                  Rails.logger.error("ERROR!: #{item.link}")
                  item.link = link_uri
                end
              end

              if Rails.env.development? && [1, 2].sample == 1
                item.link += "##{now}"
              end

              item.title = entry.title || '제목 없음'
              item.updated = entry.published.localtime
              item.summary = entry.content || entry.summary
              item.summary = replace_relative_image_url(item.summary, item.link)
              item.author = entry.author || feed_h[:author_name] || feed.title
            end
          end
        rescue => e
          puts "ERROR: #{e.inspect}"
          puts "ERROR: URL => #{feed_url}"
          next
        end
      end
      maker.channel.updated = maker.items.max_by { |x| x.updated.to_i }&.updated&.localtime || Time.now
    end

    group = params[:group] || 'none'
    report_google_analytics(@device_uid, group, request.user_agent, request.url)

    respond_to do |format|
      format.xml { render xml: @rss.to_xml }
      format.json
    end
  end

  def read
    render json: { status: 0 }
  end

  def report_google_analytics(cid, title, ua, document_url)
    # https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters
    RestClient.post('http://www.google-analytics.com/collect',
      {
        # Protocol Version
        v: '1',
        # Tracking ID
        tid: 'UA-90528160-1',
        # Client ID
        cid: cid || SecureRandom.uuid,
        # Hit type
        t: 'pageview',
        # Document location URL
        dl: document_url,
        # Document Title
        dt: title,
        ua: ua,
      },
      user_agent: ua
    )
  end

  def channel_title(category)
    case category
    when 'dev'
      'Korea Awesome Developers'.freeze
    when 'company'
      'Korea Tech Companies Blogs'.freeze
    when 'insightful'
      'Korea Insightful Blogs'.freeze
    when 'all'
      'Korea Awesome Blogs'.freeze
    else
      raise ArgumentError.new
    end
  end

  def cache_expiring_time
    if Rails.env.production?
      [20, 60, 180].sample.minutes
    else
      2.minutes
    end
  end

  def replace_relative_image_url(html_string, site_url)
    doc = Nokogiri::HTML(html_string)
    tags = {
      'img' => 'src',
      'script' => 'src',
      'a' => 'href'
    }

    base_uri = Addressable::URI.parse(site_url)
    doc.search(tags.keys.join(',')).each do |node|
      url_param = tags[node.name]

      src = node[url_param]
      unless src.blank?
        begin
          uri = Addressable::URI.parse(src)
          if uri.host.blank? || uri.scheme.blank?
            uri.scheme = base_uri.scheme
            uri.host = base_uri.host
            node[url_param] = uri.to_s
          end
        rescue Addressable::URI::InvalidURIError => _e
          #Rails.logger.error("ERROR: #{e.inspect}")
        end
      end
    end

    doc.to_html
  rescue Exception => e
    Rails.logger.error("ERROR: #{e.inspect}")
    #Rails.logger.error("HTML: #{html_string}")
    '글 읽으러 가기'
  end

end