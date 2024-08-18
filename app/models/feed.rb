class Feed
  def self.last(n)
    articles = []
    feeds = Rails.application.config_for(:feeds)['dev']

    Parallel.each(feeds, in_threads: 30) do |feed_h|
      feed_url = feed_h[:feed_url]

      feed = Rails.cache.fetch(feed_url, expires_in: 10.minutes) do
        Timeout::timeout(5) {
          xml = HTTParty.get(feed_url).body
          Feedjira.parse(xml)
        }
      end

      next if feed.nil?

      recent_entries = feed.entries.sort_by(&:published).last(1)

      recent_entries.each do |entry|
        articles << { title: entry.title, url: entry.url, published: entry.published, author: entry.author }
      end
    end

    articles.sort_by { |article| article[:published] }.reverse.first(n)
  end
end
