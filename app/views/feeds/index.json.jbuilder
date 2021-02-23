json.title @rss.title.content
json.description @rss.id.content
json.updated_at @rss.updated.content

#non_topic = NonTopic.new
json.entries @rss.entries.sort_by {|x| -x.dc_date.to_i} do |entry|
  json.author entry.author.name.content
  json.title entry.title.content
  json.link entry.link.href
  json.updated_at entry.dc_date
  # json.hidden non_topic.in?(entry.link.href)
  json.summary entry.summary.content
end