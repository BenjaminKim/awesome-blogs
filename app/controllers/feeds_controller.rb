require 'rss'
require 'open-uri'

class FeedsController < ApplicationController
  def index
    # x.scan(/xmlUrl=".*?"/).each {|x| puts x[7..-1] + ','}

    feed_urls = [
      "http://www.ecogwiki.com/sp.posts?_type=atom",
      "https://charsyam.wordpress.com/feed/",
      "http://j.mearie.org/rss",
      "http://feeds.feedburner.com/theyearlyprophet/GGGO?format=xml",
      "http://rss.egloos.com/blog/kwon37xi",
      "http://feeds.feedburner.com/xguru?format=xml",
      "http://thoughts.chkwon.net/feed/",
      "http://kwang82.hankyung.com/feeds/posts/default",
      "http://feeds.feedburner.com/goodhyun",
      "http://nolboo.github.io/feed.xml",
      "http://html5lab.kr/feed/",
      "http://www.kmshack.kr/rss",
      "http://rss.egloos.com/blog/minjang",
      "http://bomjun.tistory.com/rss",
      "http://kimbyeonghwan.tumblr.com/rss",
      "http://greemate.tistory.com/rss",
      "http://www.se.or.kr/rss",
      "https://subokim.wordpress.com/feed/",
      "http://blog.seulgi.kim/feeds/posts/default",
      "http://moogi.new21.org/tc/rss",
      "http://knight76.tistory.com/rss",
      "http://blog.rss.naver.com/drvoss.xml",
      "https://kimws.wordpress.com/feed/",
      "http://androidkr.blogspot.com/feeds/posts/default",
      "http://feeds.feedburner.com/crazytazo?format=xml",
      "http://forensic-proof.com/feed",
      "http://feeds.feedburner.com/reinblog",
      "http://www.memoriesreloaded.net/feeds/posts/default",
      "http://rss.egloos.com/blog/agile",
      "http://huns.me/feed",
      "http://taegon.kim/feed",
      "http://feeds.feedburner.com/GaeraeBlog?format=xml",
      "https://beyondj2ee.wordpress.com/feed/",
      "http://androidhuman.com/rss",
      "http://www.mickeykim.com/rss",
      "http://www.gisdeveloper.co.kr/rss",
      "http://rss.egloos.com/blog/greentec",
      "http://www.rkttu.com/atom",
      "http://bugsfixed.blogspot.com/feeds/posts/default",
      "http://occamsrazr.net/tt/index.xml",
      "http://ryulib.tistory.com/rss",
      "http://blog.lael.be/feed",
      "http://hoonsbara.tistory.com/rss",
      "http://agebreak.blog.me/rss",
      "http://likejazz.com/rss",
      "https://sangminpark.wordpress.com/feed/",
      "http://rss.egloos.com/blog/parkpd",
      "http://bagjunggyu.blogspot.com/feeds/posts/default",
      "http://feeds.feedburner.com/junyoung?format=xml",
      "http://feeds.feedburner.com/baenefit/slXh",
      "http://whiteship.me/?feed=rss2",
      "http://blog.daum.net/xml/rss/funfunction",
      "http://feeds.feedburner.com/rss_outsider_dev?format=xml",
      "http://blog.suminb.com/feed.xml",
      "http://gamecodingschool.org/feed/",
      "http://rss.egloos.com/blog/seoz",
      "https://arload.wordpress.com/feed/",
      "http://blog.saltfactory.net/feed",
      "http://emptydream.tistory.com/rss",
      "http://www.talk-with-hani.com/rss",
      "http://feeds.feedburner.com/codewiz",
      "http://zetlos.tistory.com/rss",
      "http://hyeonseok.com/rss/",
      "http://toyfab.tistory.com/rss",
      "http://qnibus.com/feed/",
      "http://blog.rss.naver.com/delmadang.xml",
      "https://only2sea.wordpress.com/feed/",
      "http://kwangshin.pe.kr/blog/feed/",
      "http://www.flowdas.com/blog/feeds/rss/",
      "http://www.enshahar.me/feeds/posts/default",
      "http://yonght.tumblr.com/rss",
      "http://feeds.feedburner.com/channy",
      "http://mobicon.tistory.com/rss",
      "http://changsuk.me/?feed=rss2",
      "https://justhackem.wordpress.com/feed/",
      "http://genesis8.tistory.com/rss",
      "http://www.buggymind.com/rss",
      "http://feeds.feedburner.com/sangwook?format=xml",
      "http://www.shalomeir.com/feed/",
      "http://blog.scaloid.org/feeds/posts/default",
      "http://blog.xcoda.net/rss",
      "http://daddycat.blogspot.com/feeds/posts/default",
      "http://feeds.feedburner.com/pyrasis?format=xml",
      "http://www.jimmyrim.com/rss",
      "http://blog.java2game.com/rss",
      "http://blog.lastmind.net/feed",
      "http://devyongsik.tistory.com/rss",
      "http://openlook.org/wp/feed/",
      "http://feeds.feedburner.com/allofsoftware?format=xml",
      "http://www.php5.me/blog/feed/",
      "http://feeds.feedburner.com/gogamza?format=xml",
      "http://www.moreagile.net/feeds/posts/default",
      "http://blrunner.com/rss",
      "http://rss.egloos.com/blog/benelog",
      "http://www.sysnet.pe.kr/rss/getrss.aspx?boardId=635954948",
      "http://health20.kr/rss",
      "http://bcho.tistory.com/rss",
      "http://sungmooncho.com/feed/",
      "http://blog.kivol.net/rss",
      "http://rss.egloos.com/blog/aeternum",
      "http://softwaregeeks.org/feed/",
      "http://blog.doortts.com/rss",
      "http://javacan.tistory.com/rss",
      "http://jacking.tistory.com/rss",
      "http://feeds.feedburner.com/Smartmob",
      "http://kkamagui.tistory.com/rss",
      "http://blog.kazikai.net/?feed=rss2",
      "https://joone.wordpress.com/feed/",
      "http://blog.dahlia.kr/rss",
      "http://blog.fupfin.com/?feed=rss2",
      "http://xrath.com/feed/",
      "http://pragmaticstory.com/feed/",
      "http://rss.egloos.com/blog/recipes",
      "http://iam-hs.com/rss",
      "http://feeds.feedburner.com/gamedevforever?format=xml",
      "http://helloworld.naver.com/rss",
      "http://www.nextree.co.kr/feed/",
      "http://blog.secmem.org/rss",
      "https://blogs.idincu.com/dev/feed/",
      "http://dev.rsquare.co.kr/feed/",
      "http://feeds.feedburner.com/acornpub",
      "http://blog.embian.com/rss",
      "http://eclipse.or.kr/index.php?title=특수기능:최근바뀜&amp;feed=atom",
      "http://blog.weirdx.io/feed/",
      "http://bigmatch.i-um.net/feed/",
      "http://blog.insightbook.co.kr/rss",
      "http://www.codingnews.net/?feed=rss2",
      "http://www.techsuda.com/feed",
      "http://tmondev.blog.me/rss",
      "http://gameplanner.cafe24.com/feed/",
      "http://feeds.feedburner.com/skpreadme?format=xml",
      "http://engineering.vcnc.co.kr/atom.xml",
      "http://feeds.feedburner.com/GoogleDevelopersKorea?format=xml",
      "http://hacks.mozilla.or.kr/feed/",
      "http://spoqa.github.io/rss",
    ]

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