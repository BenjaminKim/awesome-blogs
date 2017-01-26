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
          puts "FAILED: #{line}"
        end
      end
    end
  end
end
