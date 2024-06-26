require 'open-uri'
require 'addressable/uri'

class FeedsController < ApplicationController
  def index
    group = params[:group] || 'dev'

    recent_days = 10.days

    feeds = Rails.application.config_for(:feeds)

    if group == 'all'
      feeds = feeds.inject([]) do |array, e|
        array + e.second
      end
    else
      feeds = feeds[group]

      if group == 'dev'
        recent_days = 7.days
      elsif group == 'insightful'
        recent_days = 21.days
      end
    end

    now = Time.zone.now
    @rss = RSS::Maker.make('atom') do |maker|
      maker.channel.author = '어썸블로그'.freeze
      maker.channel.about = '국내의 좋은 블로그 글들을 매일 배달해줍니다.'.freeze
      maker.channel.title = channel_title(group)

      Parallel.each(feeds, in_threads: 30) do |feed_h|
        begin
          feed_url = feed_h[:feed_url]
          Rails.logger.debug("FEED_URL: #{feed_url}")

          feed = Rails.cache.fetch(feed_url, expires_in: cache_expiring_time) do
            Rails.logger.debug "cache missed: #{feed_url}"
            Timeout::timeout(5) {
              xml = HTTParty.get(feed_url).body
              Feedjira.parse(xml)
            }
          end

          next if feed.nil?

          if Rails.env.development?
            last_published = feed.entries.sort_by(&:published).last&.published
            if last_published
              if last_published < 3.years.ago
                Rails.logger.info "3년이 지난 피드: #{feed.title} #{feed_url}"
              end
            end
          end

          feed.entries.each do |entry|
            next unless entry.published
            if entry.published < now - recent_days || entry.published.localtime > Time.now
              next
            end
            maker.items.new_item do |item|
              link_uri = entry.url || entry.entry_id
              if link_uri.blank?
                Rails.logger.error("ERROR - url shouldn't be null: #{entry.inspect}")
                next
              end

              begin
                uri = Addressable::URI.parse(link_uri)
                uri.host ||= Addressable::URI.parse(feed_url).host
                uri.scheme ||= Addressable::URI.parse(feed_url).scheme

                item.link = add_footprint(uri).to_s
              rescue Exception => e
                Rails.logger.error("ERROR!: #{item.link} #{e}")
                item.link = link_uri
              end

              item.title = entry.title || '제목 없음'
              item.updated = entry.published.localtime
              item.content.type = 'html'
              item.content.content = replace_relative_image_url(entry.content, item.link)
              item.summary = entry.summary
              item.author = entry.author || feed_h[:author_name] || feed.title
            end
          end
        rescue => e
          Rails.logger.error "ERROR: #{e.inspect} #{feed_url}"
          next
        end
      end
      maker.channel.updated = maker.items.max_by { |x| x.updated.to_i }&.updated&.localtime || Time.now
    end

    respond_to do |format|
      format.xml {
        doc = Nokogiri::XML(@rss.to_xml)

        doc.xpath('//xmlns:summary').each do |summary|
          summary.set_attribute('type', 'html')
        end

        render xml: doc.to_xml
      }
      format.json
    end
  end

  private

  def channel_title(category)
    case category
    when 'dev'
      '개발자 어썸블로그'.freeze
    when 'company'
      '테크회사 어썸블로그'.freeze
    when 'insightful'
      '인싸이트가 있는 어썸블로그'.freeze
    when 'all'
      '어썸블로그'.freeze
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
          Rails.logger.debug "ERROR: Uri #{_e.inspect} #{site_url}"
        end
      end
    end

    doc.to_html
  rescue Exception => e
    Rails.logger.error "ERROR: #{e.inspect} #{site_url}"
  end

  def add_footprint(uri)
    previous_h = uri.query_values || {}
    uri.query_values = previous_h.merge(
      utm_source: footprint_source,
      utm_medium: 'blog',
      utm_campaign: 'asb',
    )

    uri
  end

  def footprint_source
    respond_to do |format|
      format.xml { return "awesome-blogs.petabytes.org" }
      format.json { return "awesome-blogs-app" }
    end
  end
end